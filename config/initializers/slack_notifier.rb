module SlackNotifier
  CompanyTI = Slack::Notifier.new(
    Rails.application.credentials.slack[:token_company_ti],
    channel: "#ti-alerts",
    username: "Notificaciones Iclient",
    icon_url: 'https://lh3.googleusercontent.com/P83d-3N7e2AUyku_r29v7joxpLHSD2eBfILaDKS2zsX6L4widLR62ul01HrduuBr-Hw'
  )
  Company = Slack::Notifier.new Rails.application.credentials.slack[:token_company]
  CompanyAlerts = Slack::Notifier.new(
    Rails.application.credentials.slack[:token_company_ti],
    channel: "#ti-iclient-alerts",
    username: "Alertas Iclient",
    icon_url: 'https://lh3.googleusercontent.com/P83d-3N7e2AUyku_r29v7joxpLHSD2eBfILaDKS2zsX6L4widLR62ul01HrduuBr-Hw'
  )
  CompanyQA = Slack::Notifier.new(
    Rails.application.credentials.slack[:token_company_ti],
    channel: "#qa",
    username: "Alerta Checklist",
    icon_url: 'https://lh3.googleusercontent.com/P83d-3N7e2AUyku_r29v7joxpLHSD2eBfILaDKS2zsX6L4widLR62ul01HrduuBr-Hw'
  )  
end
