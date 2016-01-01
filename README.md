# NAME

HTML::FormHandlerX::JQueryRemoteValidator

Call server-side validation code asynchronously from client-side forms.

# VERSION

Version 0.01

# SYNOPSIS

    package MyApp::Form::Foo;
    use HTML::FormHandler::Moose;

    with 'HTML::FormHandlerX::JQueryRemoteValidator';

    ...

    # You need to provide a form validation script at /ajax/formvalidator
    # In Poet/Mason, something like this in /ajax/formvalidator/dhandler.mp

    method handle () {
        $m->res->content_type('application/json');

        my ($form_name, $field_name) = split '/', $m->path_info;

        my $form = $.form($form_name);
        $form->no_update;                          # important!
        $form->process(params => $.args);

        my $err = join ' ', @{$form->field($field_name)->errors};
        my $result = $err || 'true';

        $m->print(JSON->new->allow_nonref->encode($result));
    }

# CONFIGURATION AND SETUP

`HTML::FormHandlerX::JQueryRemoteValidator` adds jQuery scripts to your form to 
gather form input and send it to the server for validation before the user submits the 
completed form. The server responds with messages that are displayed on the form. 
So you will need to set up various bits and pieces. Most have straightforward defaults.

## `validation_endpoint`

Default: /ajax/formvalidator

The form data will be POSTed to `[validation_endpoint]/[form_name]/[field_name]`.

Note that \*all\* fields are submitted, not just the field being validated. 

You must write the code to handle this submission. The response should be a JSON 
string, either `true` if the field passed its tests, or a message describing
the error. The message will be displayed on the form.

The synopsis has an example in Poet/Mason. 

## jQuery

You need to load the jQuery library yourself. See https://jquery.com/download/ 

## `jquery_validator_link`

Default: http://ajax.aspnetcdn.com/ajax/jquery.validate/1.14.0/jquery.validate.min.js

You can leave this as-is, or if you prefer, you can put the file on your own
server and modify this setting to point to it.

## `element_target_class`

Default: form-group

This identifies the CSS class of the elements that will receive the validation
success/error messages. The default (`form-group`) is for forms styled using
Bootstrap 3.

## `skip_remote_validation_types`

Default: `[ qw(Hidden noCAPTCHA Display JSON JavaScript) ]`

A list of field types that should not be included in the validation calls.

## `skip_remote_validation_fields`

Default: `[ qw(submit) ]`

A list of field names that should not be included in the validation calls.

## `skip_all_remote_validation`

Boolean, default 0.

A flag to turn off remote validation altogether, perhaps useful during form development.

## CSS

You will probably want to style the `label.error` and `label.valid` classes on your 
form, for example:

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

# See also

    - L<http://www.catalystframework.org/calendar/2012/23>
    - L<http://alittlecode.com/wp-content/uploads/jQuery-Validate-Demo/index.html>
    - L<http://jqueryvalidation.org>

# AUTHOR

David R. Baird, `<dave at zerofive.co.uk >`

# CODE REPOSITORY

["davebaird/html-formhandlerx-jqueryremotevalidator" in github.com](https://metacpan.org/pod/github.com#davebaird-html-formhandlerx-jqueryremotevalidator)

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
