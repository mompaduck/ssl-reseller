class TestMailer < ApplicationMailer
  def test_email(to_email)
    @test_time = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    
    mail(
      to: to_email,
      subject: "[CertGate] SMTP 테스트 이메일",
      from: Setting.get_string('smtp_from_email', 'noreply@certgate.com')
    )
  end
end
