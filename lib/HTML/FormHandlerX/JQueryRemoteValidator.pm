package HTML::FormHandlerX::JQueryRemoteValidator;

use HTML::FormHandler::Moose::Role;
use Method::Signatures::Simple;
use JSON ();

=head1 NAME

HTML::FormHandlerX::JQueryRemoteValidator

Call server-side validation code asynchronously from client-side forms.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

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


=cut

has_field _validation_scripts => (type => 'JavaScript', set_js_code => '_js_code_for_validation_scripts');

has validation_endpoint => (is => 'rw', isa => 'Str', default => '/ajax/formvalidator');

has jquery_validator_link => (is => 'rw', isa => 'Str', default => 'http://ajax.aspnetcdn.com/ajax/jquery.validate/1.14.0/jquery.validate.min.js');

has skip_remote_validation_fields => (is => 'rw', isa => 'ArrayRef', default => sub { [ qw(submit) ] });
has skip_remote_validation_types  => (is => 'rw', isa => 'ArrayRef', default => sub { [ qw(Hidden noCAPTCHA Display JSON JavaScript) ] });

has skip_all_remote_validation => (is => 'rw', isa => 'Bool', default => 0);

has element_target_class => (is => 'ro', isa => 'Str', default => 'form-group');

# $self is the field
method _js_code_for_validation_scripts () {
    my $spec_data = $self->form->_data_for_validation_spec;
    my $spec = JSON->new->utf8
                        ->allow_nonref
                        ->pretty(1)
                        ->relaxed(undef)
                        ->canonical(undef)
                        ->encode($spec_data)
                         || '';

    $spec =~ s/"data_collector"/data_collector/g;
    $spec =~ s/\n$//;
    $spec = "\n  var validation_spec = $spec;\n";
    return $self->_data_collector_script . $spec . $self->form->_run_validator_script;
}

method _data_for_validation_spec () {
    my $js_profile = { rules => {}, messages => {} };

    foreach my $field ( @{$self->fields}) {
        next if $self->_skip_remote_validation($field);       # don't build rules for these fields
        $js_profile->{rules}->{$field->id}->{remote} = $self->_build_remote_rule($field);
    }

    return $js_profile;
}

method _build_remote_rule ($field) {
    my $remote_rule = {
        url => sprintf("%s/%s/%s", $self->validation_endpoint, $self->name, $field->name),
        type => 'POST',
        data => 'data_collector',
        };

    return $remote_rule;
}

method _data_collector_script () {
    my $script = join(",\n", 
                    map { sprintf "    \"%s.%s\": function () { return \$(\"#%s\\\\.%s\").val() }", $self->name, $_->name, $self->name, $_->name }
                    grep { ! $self->_skip_remote_validation($_) }
                    $self->fields
                    );

    return "  var data_collector = {\n" . $script . "\n  };\n";
}

method _skip_remote_validation ($field) {
    return 1 if $self->skip_all_remote_validation;
    my %skip_field = map {$_=>1} @{$self->skip_remote_validation_fields};
    my %skip_type  = map {$_=>1} @{$self->skip_remote_validation_types};
    return 1 if $skip_field{$field->name};
    return 1 if $skip_type{$field->type};
    return 0;
}

method _run_validator_script () {
    my $form_name = $self->name;
    my $link = $self->jquery_validator_link;
    my $css_target = $self->element_target_class;

    my $script = <<SCRIPT;

  \$(document).ready(function() {
    \$.getScript("$link", function () {
      if (typeof validation_spec !== 'undefined') {
        \$('form#$form_name').validate({
          rules: validation_spec.rules,
          messages: validation_spec.messages,
          highlight: function(element) {
            \$(element).closest('.$css_target').removeClass('success').addClass('error');
          },
          success: function(element) {
            element
            .text('dummy').addClass('valid')
            .closest('.$css_target').removeClass('error').addClass('success');
          }
        });
      }
    });
  });
SCRIPT

    return $script;
}


=head1 CONFIGURATION AND SETUP

C<HTML::FormHandlerX::JQueryRemoteValidator> adds jQuery scripts to your form to 
gather form input and send it to the server for validation before the user submits the 
completed form. The server responds with messages that are displayed on the form. 
So you will need to set up various bits and pieces. Most have straightforward defaults.

=head2 C<validation_endpoint>

Default: /ajax/formvalidator

The form data will be POSTed to C<[validation_endpoint]/[form_name]/[field_name]>.

Note that *all* fields are submitted, not just the field being validated. 

You must write the code to handle this submission. The response should be a JSON 
string, either C<true> if the field passed its tests, or a message describing
the error. The message will be displayed on the form.

The synopsis has an example in Poet/Mason. 

=head2 jQuery

You need to load the jQuery library yourself. See https://jquery.com/download/ 

=head2 C<jquery_validator_link>

Default: http://ajax.aspnetcdn.com/ajax/jquery.validate/1.14.0/jquery.validate.min.js

You can leave this as-is, or if you prefer, you can put the file on your own
server and modify this setting to point to it.

=head2 C<element_target_class>

Default: form-group

This identifies the CSS class of the elements that will receive the validation
success/error messages. The default (C<form-group>) is for forms styled using
Bootstrap 3.

=head2 C<skip_remote_validation_types>

Default: C<[ qw(Hidden noCAPTCHA Display JSON JavaScript) ]>

A list of field types that should not be included in the validation calls.

=head2 C<skip_remote_validation_fields>

Default: C<[ qw(submit) ]>

A list of field names that should not be included in the validation calls.

=head2 C<skip_all_remote_validation>

Boolean, default 0.

A flag to turn off remote validation altogether, perhaps useful during form development.


=head2 CSS

You will probably want to style the C<label.error> and C<label.valid> classes on your 
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

=cut




=head1 See also

    - L<http://www.catalystframework.org/calendar/2012/23>
    - L<http://alittlecode.com/wp-content/uploads/jQuery-Validate-Demo/index.html>
    - L<http://jqueryvalidation.org>

=cut

=head1 AUTHOR

David R. Baird, C<< <dave at zerofive.co.uk > >>

=head1 CODE REPOSITORY

L<github.com/davebaird/html-formhandlerx-jqueryremotevalidator>

Please report any bugs or feature requests there.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::FormHandlerX::JQueryRemoteValidator


You can also look for information at:

=over 4

=item * MetaCPAN

L<https://metacpan.org/pod/HTML::FormHandlerX::JQueryRemoteValidator>


=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-FormHandlerX-JQueryRemoteValidator>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-FormHandlerX-JQueryRemoteValidator/>

=back


=head1 ACKNOWLEDGEMENTS

This started out as a modification of Aaron Trevana's
HTML::FormHandlerX::Form::JQueryValidator


=head1 LICENSE AND COPYRIGHT

Copyright 2016 David R. Baird.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

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


=cut

1; # End of HTML::FormHandlerX::JQueryRemoteValidator
