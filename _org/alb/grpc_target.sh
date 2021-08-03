  alb=$(aws cloudformation list-exports \
      --query "Exports[?Name=='cf-ALB'].Value" \
      --output text)
  curl http://$alb
