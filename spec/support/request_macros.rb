# -*- coding: utf-8 -*-
module RequestMacros
  def prepare_for_mid_1_uid_1
    # mid = 1, uid = 1 のデータを用意する
    @medium = create(:medium, id: 1)
    @media_user = create(:media_user, id: 1, medium: @medium)
  end
end
