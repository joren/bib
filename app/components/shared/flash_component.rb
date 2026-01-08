class Shared::FlashComponent < ViewComponent::Base
  FLASH_CLASSES = {
    notice: "bg-green-50 text-green-800 border-green-200",
    alert: "bg-red-50 text-red-800 border-red-200",
    error: "bg-red-50 text-red-800 border-red-200"
  }.freeze

  def initialize(type:, message:)
    @type = type.to_sym
    @message = message
  end

  def flash_classes
    FLASH_CLASSES[@type] || FLASH_CLASSES[:notice]
  end
end
