# -*- coding: utf-8 -*-
class Point < ActiveRecord::Base
  belongs_to :media_user

  belongs_to :source, :polymorphic => true

  # belongs_to_active_hash :point_type  # 古い？
  belongs_to :point_type
end
