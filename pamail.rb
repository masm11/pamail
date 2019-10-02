#!/usr/bin/env ruby

# Your smtp server must support STARTTLS.
#
# /etc/pamail.rc ------------
# MAIL_FROM = ''
# MAIL_TO   = ''
# SMTP_HOST = ''
# SMTP_PORT = 587
# SMTP_HELO = ''
# SMTP_USER = ''
# SMTP_PASS = ''
# ---------------------------

require 'syslog'
require 'net/smtp'

load '/etc/pamail.rc'

Syslog.open('pamail', Syslog::LOG_PID, Syslog::LOG_MAIL)

subj = ARGV[0]
body = $stdin.readlines chomp: true

Syslog.log(Syslog::LOG_INFO, "Subject: %s", subj)

class Sender

  def initialize(subj, body)
    @subj = subj   # str
    @body = body   # array of lines
  end

  def send
    smtp = Net::SMTP.new SMTP_HOST, SMTP_PORT
    smtp.enable_starttls
    smtp.start SMTP_HELO, SMTP_USER, SMTP_PASS do |smtp|
      smtp.send_message <<~EOT, MAIL_FROM, MAIL_TO
      To: <#{MAIL_TO}>
      From: <#{MAIL_FROM}>
      Subject: #{@subj}
      
      #{@body.join("\n")}
      EOT
    end
  end

end

sender = Sender.new(subj, body)

10.times do |i|
  sleep Math.exp(i)
  begin
    sender.send
    break
  rescue Exception => e
    Syslog.log(Syslog::LOG_ERR, "%s", e.to_s)
    e.backtrace.each do |bt|
      Syslog.log(Syslog::LOG_ERR, "%s", bt)
    end
  end
end
