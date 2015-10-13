# -*- coding: utf-8 -*-
class MediaUser < ActiveRecord::Base
  has_many :points
  belongs_to :medium

  has_one :media_user_update

  has_many :terminal_androids

  # 有効な端末
  def terminal
    # とりあえずは Android のみ考慮
    terminals = terminal_androids.where(available: true)
    if terminals.size != 1
      # TODO: 全 Model で共通のメソッドを定義するには？
      #logger_fatal "Terminal is not 1(#{terminal_androids.size}). (MadiaUser.id = #{id})"
      return nil
    else
      return terminals[0]
    end
  end

  # キャンペーンに対応した成果数
  def count_achievement_by_campaign(campaign)
    return Achievement.where(media_user: self).where(campaign: campaign).size
  end

  def version
    return nil if terminal.nil?

    terminal.version
  end

  def brand
    return nil if terminal.nil?

    terminal.brand
  end

  def model
    return nil if terminal.nil?

    terminal.model
  end

  # ユーザーキー生成
  def self.make_user_key
    return SecureRandom.hex(8)
  end
end
