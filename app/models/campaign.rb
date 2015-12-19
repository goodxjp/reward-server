# -*- coding: utf-8 -*-
class Campaign < ActiveRecord::Base
  # 売上先
  belongs_to :network

  # キャンペーンの入手経路 (ソース)
  belongs_to :campaign_source  # source のみで一意に決まりそうだが、手動で登録するときは source データがないこともあるので、このカラムは必須。
  belongs_to :source, polymorphic: true

  belongs_to :campaign_category

  has_many :offers

  has_many :achievements
  has_many :points, :as => :source

  has_and_belongs_to_many :media

  # Validations
  validates :network, presence: true
  # URL スキームの時は campaign_source と source_campaign_identifier を null にした方がいいかも
  validates :campaign_source, presence: true
  # DB には source_campaign_identifier の一意性制約をつけていない (後で変わりそうなので) ので、気休め程度。
  validates :source_campaign_identifier,
#    presence: true,
#    format: { with: /\A\w+\z/ },
    uniqueness: { scope: [:campaign_source] }
  validates :campaign_category, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true
  validates :price,
    :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :payment,
    :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :point,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 },
    :allow_nil => true

  #
  # 関連オファーを更新する
  #
  # - トランザクション、ロックは上位でかけること。
  #
  def update_related_offers
    #
    # [before] 更新前に有効なオファー一覧 (無効化候補)
    #
    before_offers = self.offers.where(available: true).to_a
    # to_a しておかないと SQL が実行されず。以下で Offer を追加したものも含まれてしまう。
    #puts "before_offers.size = #{before_offers.size}"

    #
    # [after] 更新後に有効になるオファー一覧 (ID が決まっていないので、実際はメディアのリスト)
    #
    if self.available
      # 今回、有効になるオファー一覧 (メディアのリスト) で回して、追加 or 更新を実施する
      self.media.each do |medium|
        # 追加か？更新か？ (現在のキャンペーンの値とメディアに対応したオファーが存在するか？)
        offer = Offer.offer_from_campaign_and_medium(self, medium)

        if offer.nil?
          # 追加
          new_offer = Offer.new_from_campaign(self, medium)
          new_offer.available = true
          new_offer.save!
        else
          # 更新
          offer.available = true
          offer.save!

          # 処理済みということで無効化対象から外す
          before_offers.delete_if { |o| o.id == offer.id }
        end
      end
    end

    # 無効化候補に残ったオファーを無効化
    #puts "before_offers.size = #{before_offers.size}"
    before_offers.each do |offer|
      offer.available = false
      offer.save!
    end
  end
end
