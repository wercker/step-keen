#!/bin/bash
#source build-esen.sh

if [ -z "$WERCKER_KEEN_WRITE_KEY" ]; then
  fail "Please provide a valid Keen write key";
fi

if [ -z "$WERCKER_KEEN_PROJECT_ID" ]; then
  fail "Please provide a valid Keen project ID";
fi

if [ -z "$WERCKER_KEEN_EVENT_NAME" ]; then
  fail "Please provide a valid Keen event name";
fi

if [ -n "$DEPLOY" ]; then
  export ACTION="deploy"
  export ACTION_URL=$WERCKER_DEPLOY_URL
else
  export ACTION="build"
  export ACTION_URL=$WERCKER_BUILD_URL
fi

json="{
  \"application_name\":\"$WERCKER_APPLICATION_NAME\",
  \"build_id\": \"$WERCKER_BUILD_ID\",
  \"triggered_by\": \"$WERCKER_STARTED_BY\",
  \"action\": \"$ACTION\",
  \"URL\": \"$ACTION_URL\",
  \"result\": \"$WERCKER_RESULT\"
"

if [ "$WERCKER_RESULT" == "failed" ]; then
  json=$json",
    \"failed_step\": \"$WERCKER_FAILED_STEP_DISPLAY_NAME\"
  "
fi

json=$json"}"
echo $json
curl https://api.keen.io/3.0/projects/$WERCKER_KEEN_PROJECT_ID/events/$WERCKER_KEEN_EVENT_NAME \
  -H "Authorization: $WERCKER_KEEN_WRITE_KEY" \
  -H "Content-type: application/json" \
  -d "$json"
