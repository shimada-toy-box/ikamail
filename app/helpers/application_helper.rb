# frozen_string_literal: true

module ApplicationHelper
  def controller_sym
    controller_name.singularize.intern
  end

  def action_sym
    action_name.intern
  end

  # 翻訳系
  def t_model(model = controller_sym, count: 1)
    t(model, scope: [:activerecord, :models], count: count)
  end

  def t_title(title, model: controller_sym, count: 1)
    t(title, scope: [:titles], model: t_model(model, count: count))
  end

  def t_menu_action(attr, model:, count: 1)
    t(attr, scope: [:menu, :actions], model: t_model(model, count: count))
  end

  def t_attr(attr, model: controller_sym)
    t(attr, scope: [:activerecord, :attributes, model])
  end

  def menu_list
    list = []
    return list unless user_signed_in?

    if current_user.admin?
      list << {
        path: admin_root_path,
        label: t(:admin_root, scope: [:menu, :paths]),
      }
    end
    list << {
      path: new_bulk_mail_path,
      label: t_menu_action(:new, model: :bulk_mail),
    }
    list << {
      path: bulk_mails_path,
      label: t_menu_action(:index, model: :bulk_mail, count: 2),
    }
    list << {
      path: templates_path,
      label: t_menu_action(:index, model: :template, count: 2),
    }
    list << {
      path: recipient_lists_path,
      label: t_menu_action(:index, model: :recipient_list, count: 2),
    }
  end

  def dt_dd_tag(term, &block)
    content_tag('div', class: 'row border-bottom mb-2 pb-2') do
      content_tag('dt', term, class: 'col-sm-6 col-md-4 col-xl-2') +
        content_tag('dd', class: 'col-sm-6 col-md-8 col-xl-10 mb-0', &block)
    end
  end

  def dt_dd_for(recored, attr, **opts, &block)
    if block_given?
      dt_dd_tag recored.class.human_attribute_name(attr) do
        yield recored.__send__(attr)
      end
    else
      dt_dd_for(recored, attr, opts) do |value|
        case value
        when nil
          content_tag('span', opts[:blank_alt] || t(:none, scope: :values), class: 'font-italic text-muted')
        when '', [], {}
          content_tag('span', opts[:blank_alt] || t(:empty, scope: :values), class: 'font-italic text-muted')
        when String
          case opts[:format]
          when :mail_body
            mail_body_tag(value, **opts)
          when :translate
            span_text_tag(t(value, scope: opts[:scope]), **opts)
          else
            span_text_tag(value, **opts)
          end
        when Time, Date, DateTime, ActiveSupport::TimeWithZone
          content_tag('span', l(value, format: opts[:format]))
        when true, false
          content_tag('div', class: 'custom-control custom-switch') do
            check_box_tag(:admin?, '1', value, disabled: true, class: 'custom-control-input') +
              label_tag(:admin?, '', class: 'custom-control-label')
          end
        else
          content_tag('span', value.to_s)
        end
      end
    end
  end

  def mail_body_tag(value, **opts)
    content_tag('pre', value, class: 'border rounded mb-0 mail-body line-76-80') do
      span_text_tag(value, **opts)
    end
  end

  def span_text_tag(value, around: nil, **_)
    if around.present?
      content_tag('span', around[0], class: 'text-muted') +
        content_tag('span', value) +
        content_tag('span', around[1], class: 'text-muted')
    else
      content_tag('span', value)
    end
  end
end
