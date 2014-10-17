class MyFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, label, options = {})
    label(attribute, label) + super(attribute, options.merge({:class => "ipt-text", :placeholder => label}))
  end

  def password_field(attribute, label, options = {})
    label(attribute, label) + super(attribute, options.merge({:class => "ipt-text", :placeholder => label}))
  end

  def submit(label, options = {})
    @template.content_tag(:div,
      @template.submit_tag(
        label, objectify_options(options.merge({:class => "button-primary"}))
      ),
      :class => "r form-action-r"
    )
  end
end
