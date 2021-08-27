  ExportName=${DeploymentName}-ALB

  alb=$(aws cloudformation list-exports \
      --query "Exports[?Name=='${DeploymentName}-ALB'].Value" \
      --output text)

  curl http://$alb
