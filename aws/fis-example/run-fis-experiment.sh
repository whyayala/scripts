
set -eo pipefail
source ../utils.sh

STACK_NAME="stack-name"
INSTANCE_ALARM_LOGICAL_RESOURCE_ID="InstanceRebootAlarm"
SYTEM_ALARM_LOGICAL_RESOURCE_ID="SystemRecoveryAlarm"

# Pre-existing stack with the defined logical resource ids is required for this to work
get_instance_alarm() {
    alarm_name=$(get_physical_resource_id $STACK_NAME $INSTANCE_ALARM_LOGICAL_RESOURCE_ID)

    aws cloudwatch describe-alarms \
        --alarm-names $alarm_name \
        --query='MetricAlarms[0].AlarmArn' \
        --output=text
}

get_system_alarm() {
    alarm_name=$(get_physical_resource_id $STACK_NAME $SYTEM_ALARM_LOGICAL_RESOURCE_ID)

    aws cloudwatch describe-alarms \
        --alarm-names $alarm_name \
        --query='MetricAlarms[0].AlarmArn' \
        --output=text
}

# Deploy template with FIS experiment definition. Experiment will stop if the provided alarms go off. Note that the alarms provided are not linked to the instance being tested.
sam deploy --parameter-overrides \
    PrimaryInstanceId=$(get_physical_resource_id $STACK_NAME EC2Instance) \
    InstanceAlarm=$(get_instance_alarm) \
    SystemAlarm=$(get_system_alarm)

# Get experiment id
EXPERIMENT_ID=$(aws fis start-experiment \
    --experiment-template-id $(get_physical_resource_id fis-tests-stack FailoverTest) \
    --query='experiment.id' \
    --output=text
)
# Get Experiment status
EXPERIMENT_STATUS=$(aws fis get-experiment \
    --id $EXPERIMENT_ID \
    --query='experiment.state.status' \
    --output=text
);

# Ping the status and exit 1 on failed experiment
while [ $EXPERIMENT_STATUS != "completed" ]; do
    sleep 30s;
    EXPERIMENT_STATUS=$(aws fis get-experiment \
        --id $EXPERIMENT_ID \
        --query='experiment.state.status' \
        --output=text
    );
    echo "Experiment status is $EXPERIMENT_STATUS";
    if [ $EXPERIMENT_STATUS == 'stopped' ] || [ $EXPERIMENT_STATUS == 'failed' ]; then
        echo 'Exiting due to stopped or failed experiment.';
        exit 1
    fi
done
