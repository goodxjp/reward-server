# -*- coding: utf-8 -*-
module RequestMacros
  def prepare_for_mid_1_uid_1
    # mid = 1, uid = 1 のデータを用意する
    @medium = create(:medium, id: 1)
    @media_user = create(:media_user, id: 1, medium: @medium)
  end

  # ユーザーにポイントを与える
  def add_point(media_user, point_num)
    # 数字としての「ポイント数」と資産としての「ポイントオブジェクト」がいつも point で被る。
    # ポイント数を point_num にする。point_number でもいいけど number の略語は一般的だし num でいいかも。

    #Point::add_point(@media_user, PointType::MANUAL, 1000, "テスト用")
    #↑こっちの方がリアルっぽいけど、DB を完全に把握しておいた方がいいかな。point も後で使いたいし。
    point = create(:point, media_user: media_user, point: point_num, remains: point_num)
    media_user.point = point_num
    media_user.save!

    return point
  end
end
