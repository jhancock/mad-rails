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
        label, objectify_options(options.merge({:class => "btn btn-primary"}))
      ),
      :class => "form-action clearfix"
    )
  end

  def submit_no_div(label, options = {})
    @template.submit_tag(
      label, objectify_options(options.merge({:class => "btn btn-primary"}))
    )
  end

end
