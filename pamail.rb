#!/usr/bin/env ruby

# mail client to send to particular mail address.
# Copyright (C) 2019 Yuuki Harano
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


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
