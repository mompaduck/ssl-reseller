# app/controllers/certificates_controller.rb
require "ostruct"   # 이 줄을 꼭 추가하세요

class CertificatesController < ApplicationController
  # 'index' 액션에 대해서만 로그인 요구를 건너뜁니다.
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @certificate_types = [
      OpenStruct.new(key: "dv", label: "DV 인증서", description: "도메인 검증형 인증서"),
      OpenStruct.new(key: "ov", label: "OV 인증서", description: "기업 실체 검증형 인증서"),
      OpenStruct.new(key: "ev", label: "EV 인증서", description: "최고 수준 기업 검증형 인증서")
    ]
  end
end