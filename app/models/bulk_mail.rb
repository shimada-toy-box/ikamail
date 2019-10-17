# frozen_string_literal: true

require 'mustache'

class BulkMail < ApplicationRecord
  STATUS_LIST = %w[
    draft
    pending
    reserved
    ready
    waiting
    delivery
    derivered
    failure
  ].freeze

  TIMING_LIST = %w[
    immediate
    reservation
    manual
  ].freeze

  ACTION_LIST = %w[
    create
    edit
    update
    destroy
    apply
    withdraw
    approve
    reject
    reserve
    deliver
    finish
  ].freeze

  validates :status, inclusion: {in: STATUS_LIST}
  validates :delivery_timing, inclusion: {in: TIMING_LIST}

  belongs_to :bulk_mail_template
  belongs_to :user

  def body_header
    text = Mustache.render(bulk_mail_template.body_header, individual_values)
    if text&.present? && !text.end_with?("\n")
      text + "\n"
    else
      text
    end
  end

  def body_footer
    text = bulk_mail_template.body_footer
    if text&.present? && !text.end_with?("\n")
      text + "\n"
    else
      text
    end
  end

  def mail_subject
    str = String.new
    str << bulk_mail_template.subject_prefix % individual_values
    str << subject
    str << bulk_mail_template.subject_postfix % individual_values
    str
  end

  def mail_body
    str = String.new
    str << bulk_mail_template.body_header % individual_values
    str << body
    str << bulk_mail_template.body_fotter % individual_values
    str
  end

  private def individual_values
    number_str = number&.to_s || "42"
    datetime = delivery_datetime || DateTime.now
    {
      number: number_str,
      number_zen: number_str.tr('0-9', '０-９'),
      number_kan: number_str.tr('0-9', '〇一ニ三四五六七八九'),
      name: bulk_mail_template.name,
      datetime: I18n.t(datetime),
      # date: I18n.t(datetime.date),
      # time: I18n.(datetime.time),
    }
  end

end
