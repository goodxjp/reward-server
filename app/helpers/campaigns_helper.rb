# -*- coding: utf-8 -*-
module CampaignsHelper
  #
  # ネットワークシステムごとのキャンペーン詳細表示で使う text 用フォームグループ
  #
  def fg_readonly_text(name, value, has_error = false)
    if has_error
      classes = { class: 'form-group has-error' }
    else
      classes = { class: 'form-group' }
    end
    content_tag(:div, classes) do
      n = content_tag(:label, { class: 'col-md-4 control-label' }) do
        name
      end
      v = content_tag(:div, { class: 'col-md-8' }) do
        content_tag(:div, { class: 'form-control' }) do
          value.to_s
        end
      end

      n + v
    end
  end

  #
  # ネットワークシステムごとのキャンペーン詳細表示で使う textarea 用フォームグループ
  #
  def fg_readonly_textarea(name, value, rows = 1, has_error = false)
    if has_error
      classes = { class: 'form-group has-error' }
    else
      classes = { class: 'form-group' }
    end
    content_tag(:div, classes) do
      n = content_tag(:label, { class: 'col-md-4 control-label' }) do
        name
      end
      v = content_tag(:div, { class: 'col-md-8' }) do
        content_tag(:textarea, { class: 'form-control', rows: rows, readonly: true }) do
          value.to_s
        end
      end

      n + v
    end
  end
end
