# app/models/certificate.rb
class Certificate < ApplicationRecord
  belongs_to :order
  belongs_to :user  # 만약 사용자 정보가 필요하다면 추가

  # 인증서 상태(enum) 정의 
  enum status: {
    pending:   "pending",   # 발급 대기
    issued:    "issued",    # 발급 완료
    expired:   "expired",   # 만료됨
    revoked:   "revoked"    # 폐기됨
  }, _default: "pending", _suffix: true

  # 인증서 종류(enum) (예: DV, OV, EV) — 만약 certificate_type 컬럼이 있다면
  enum certificate_type: {
    dv: "dv",
    ov: "ov",
    ev: "ev"
  }, _prefix: true, _default: "dv"

  # 유효성 검증
  validates :serial_number, presence: true, uniqueness: true
  validates :certificate_body, presence: true, if: :issued_status?
  validates :expires_at, presence: true, if: :issued_status?
  validates :status, inclusion: { in: statuses.keys }

  # 스코프 정의
  scope :recent, -> { order(issued_at: :desc) }
  scope :active, -> { issued.where("expires_at > ?", Time.current) }

  # 헬퍼 메서드
  def issued_status?
    status == "issued"
  end

  def expired?
    status == "expired"
  end

  def revoke!
    update!(status: "revoked", revoked_at: Time.current)
  end
end