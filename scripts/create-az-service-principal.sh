az ad sp create-for-rbac \
  --name "action-test" \
  --role contributor \
  --scopes /subscriptions/b57b253a-e19e-4a9c-a0c0-a5062910a749 \
  --sdk-auth