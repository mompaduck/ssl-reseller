class HomeController < ApplicationController
  # 이 액션(index)에 대해서는 인증 요구 사항을 건너뜁니다.
  skip_before_action :authenticate_user!, only: [:index]

  def index
    # 랜딩 페이지를 보여주는 액션
  end

  def contact
  end
end
