# NAME

HTML::FormHandlerX::JQueryRemoteValidator - call server-side validation code asynchronously from client-side forms.

# VERSION

Version 0.2

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

The purpose of this package is to automatically build a set of JQuery scripts
and inject them into your forms. The scripts send user input to your server
where you must provide an endpoint that can validate the fields. Since you
already have an HTML::FormHandler form, you can use that. The synopsis has a
straightforward example of how to do it. 

The package uses the remote validation feature of the JQuery Validator
framework. This also takes care of updating your form to notify the user of
errors and successes while they fill in the form, but you will most likely want
to customise that behaviour for your own situation. An example is given below.

## What you need

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
through the form, but for a better user experience JQuery Validator offers lots
of options. You can read about them at [http://jqueryvalidation.org/validate/](http://jqueryvalidation.org/validate/).
You should start by reading the few sentences at the very bottom of that page.

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

Default: `[ qw(Hidden noCAPTCHA Display JSON JavaScript) ]`

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

# AUTHOR

David R. Baird, `<dave at zerofive.co.uk>`

# CODE REPOSITORY

[http://github.com/davebaird/html-formhandlerx-jqueryremotevalidator](http://github.com/davebaird/html-formhandlerx-jqueryremotevalidator)

Please report any bugs or feature requests there.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::FormHandlerX::JQueryRemoteValidator

You can also look for information at:

- MetaCPAN

    [https://metacpan.org/pod/HTML::FormHandlerX::JQueryRemoteValidator](https://metacpan.org/pod/HTML::FormHandlerX::JQueryRemoteValidator)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator](http://annocpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator)

- CPAN Ratings

    [http://cpanratings.perl.org/d/HTML-FormHandlerX-JQueryRemoteValidator](http://cpanratings.perl.org/d/HTML-FormHandlerX-JQueryRemoteValidator)

- Search CPAN

    [http://search.cpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator/](http://search.cpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator/)

# ACKNOWLEDGEMENTS

This started out as a modification of Aaron Trevana's
HTML::FormHandlerX::Form::JQueryValidator

# LICENSE AND COPYRIGHT

Copyright 2016 David R. Baird.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
