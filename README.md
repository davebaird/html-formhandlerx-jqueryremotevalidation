# NAME

HTML::FormHandlerX::JQueryRemoteValidator

# VERSION

version 0.22

# SYNOPSIS

    package MyApp::Form::Foo;
    use HTML::FormHandler::Moose;

    with 'HTML::FormHandlerX::JQueryRemoteValidator';

    ...

    # You need to provide a form validation script at /ajax/formvalidator
    # In Poet/Mason, something like this in /ajax/formvalidator.mp -

    route ':form_name/:field_name';

    method handle () {
        my $form = $.form($.form_name);
        $form->process(params => $.args, no_update => 1);

        my $err = join ' ', @{$form->field($.field_name)->errors};
        my $result = $err || 'true';

        $m->print(JSON->new->allow_nonref->encode($result));
    }

# CONFIGURATION AND SETUP

The purpose of this package is to build a set of JQuery scripts and inject them
into your forms. The scripts send user input to your server where you must
provide an endpoint that can validate the fields. Since you already have an
HTML::FormHandler form, you can use that.

The package uses the remote validation feature of the JQuery Validator
framework. This also takes care of updating your form to notify the user of
errors and successes while they fill in the form. You will most likely want
to customise that behaviour for your own situation. An example is given below.

## What you will need

- JQuery

    Load the JQuery library somewhere on your page.

- JQuery validator

    See the `jquery_validator_link` attribute.

- Server-side validation endpoint

    See the `validation_endpoint` attribute.

- Some JS fragments to update the form
- CSS to prettify it all

## An example using the Bootstrap 3 framework

### Markup

    <form ...>

    <div class="form-group form-group-sm">
        <label class="col-xs-3 control-label" for="AddressForm.name"></label>
        <div class="col-xs-6">
            <input type="text" name="AddressForm.name" id="AddressForm.name"
                class="form-control" value="" />
        </div>
        <label for="AddressForm.name" id="AddressForm.name-error"
            class="has-error control-label col-xs-3">
        </label>
    </div>

    <div class="form-group form-group-sm">
        <label class="col-xs-3 control-label" for="AddressForm.address"></label>
        <div class="col-xs-6">
            <input type="text" name="AddressForm.address" id="AddressForm.address"
                class="form-control" value="" />
        </div>
        <label for="AddressForm.address" id="AddressForm.address-error"
            class="has-error control-label col-xs-3">
        </label>
    </div>

    ...

    </form>

### CSS

Most of the classes on the form come from Twitter Bootstrap 3. In this example,
JQuery validator targets error messages to the second &lt;label> on each
form-control. This is the default behaviour but can be changed.

The default setup will display and remove messages as the user progresses
through the form. JQuery Validator offers lots of options. You can read about
them at [http://jqueryvalidation.org/validate/](http://jqueryvalidation.org/validate/). You should start by reading
the few sentences at the very bottom of that page.

Some useful additional styling to get started:

    label.valid {
      width: 24px;
      height: 24px;
      background: url(/static/images/valid.png) center center no-repeat;
      display: inline-block;
      text-indent: -9999px;
    }

    label.error {
      font-weight: normal;
      color: red;
      padding: 2px 8px;
      margin-top: 2px;
    }

### JavaScript

You can provide extra JavaScript functions to control the behaviour of the error
and success messages in the `jqr_validate_options` attribute:

    my $jqr_validate_options = {
        highlight => q/function(element, errorClass, validClass) {
                $(element).closest('.form-group').addClass(errorClass).removeClass(validClass);
                $(element).closest('.form-group').find("label").removeClass("valid");
            }/,
        unhighlight => q/function(element, errorClass, validClass) {
                $(element).closest('.form-group').removeClass(errorClass);
            }/,
        success => q/function(errorLabel, element) {
                $(element).closest('.form-group').addClass("has-success");
                errorLabel.addClass("valid");
            }/,
        errorClass => '"has-error"',
        validClass => '"has-success"',
        errorPlacement => q/function(errorLabel, element) {
                errorLabel.appendTo( element.parent("div").parent("div") );
            }/,
    };

    has '+jqr_validate_options' => (default => sub {$jqr_validate_options});

## Class (form) attributes

### `validation_endpoint`

Default: /ajax/formvalidator

The form data will be POSTed to `[validation_endpoint]/[form_name]/[field_name]`.

Note that \*all\* fields are submitted, not just the field being validated.

You must write the code to handle this submission. The response should be a JSON
string, either `true` if the field passed its tests, or a message describing
the error. The message will be displayed on the form.

The synopsis has an example for Poet/Mason.

### `jquery_validator_link`

Default: http://ajax.aspnetcdn.com/ajax/jquery.validate/1.14.0/jquery.validate.min.js

You can leave this as-is, or if you prefer, you can put the file on your own
server and modify this setting to point to it.

### `jquery_validator_opts`

Default: {}

A HashRef, keys being the keys of the `validate` JQuery validator call documented
at [http://jqueryvalidation.org/validate/](http://jqueryvalidation.org/validate/), with values being JavaScript functions
etc. as described there.

### `skip_remote_validation_types`

Default: `[ qw(Submit Hidden noCAPTCHA Display JSON JavaScript) ]`

A list of field types that should not be included in the validation calls.

### `skip_all_remote_validation`

Boolean, default 0.

A flag to turn off remote validation altogether, perhaps useful during form development.

## Field attributes

### Tag `no_remote_validate` \[`Bool`\]

Default: not set

Set this tag to a true value on fields that should not be remotely validated:

    has_field 'foo' => (tags => {no_remote_validate => 1}, ... );

# See also

- [http://www.catalystframework.org/calendar/2012/23](http://www.catalystframework.org/calendar/2012/23)
- [http://alittlecode.com/wp-content/uploads/jQuery-Validate-Demo/index.html](http://alittlecode.com/wp-content/uploads/jQuery-Validate-Demo/index.html)
- [http://jqueryvalidation.org](http://jqueryvalidation.org)

# ACKNOWLEDGEMENTS

This started out as a modification of Aaron Trevana's
HTML::FormHandlerX::Form::JQueryValidator

# AUTHOR

Dave Baird &lt;dave@zerofive.co.uk>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by David R. Baird.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
