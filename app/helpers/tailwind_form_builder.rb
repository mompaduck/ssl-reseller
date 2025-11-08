# app/helpers/tailwind_form_builder.rb
class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    options[:class] = "#{base_input_classes} #{options[:class]}"
    super(method, options)
  end

  def email_field(method, options = {})
    options[:class] = "#{base_input_classes} #{options[:class]}"
    super(method, options)
  end

  def password_field(method, options = {})
    options[:class] = "#{base_input_classes} #{options[:class]}"
    super(method, options)
  end

  def telephone_field(method, options = {})
    options[:class] = "#{base_input_classes} #{options[:class]}"
    super(method, options)
  end

  def submit(value = nil, options = {})
    options[:class] = "#{base_submit_classes} #{options[:class]}"
    super(value, options)
  end

  private

  def base_input_classes
    "w-full border border-gray-300 rounded-lg py-3 px-3 focus:ring-2 focus:ring-indigo-600 focus:border-transparent transition placeholder-gray-400 text-gray-900 bg-white"
  end

  def base_submit_classes
    "w-full bg-gradient-to-r from-blue-600 to-green-600 text-white py-3 rounded-lg font-semibold hover:opacity-90 transition cursor-pointer"
  end
end