#This Code is Licenced under the Perl Artistic License
#you might have been able to get this License if you got this Code

use strict;

my ($watch, $prefix) =
("", 'activityWatcher-');

sub on_start
{
  my ($term) = @_;

  $term->parse_keysym("M-C-a", "perl:$prefix"."activity");
  $term->parse_keysym("M-C-i", "perl:$prefix"."inactivity");

  ()
}

sub on_user_command
{
  my ($term, $string) = @_;

  if($string =~ /$prefix(.*)$/)
  {
    if($watch eq $1)
    {
      $watch = '';
      delete $term->{activity_ov};
      delete $term->{inactivity_timer};
    }
    else
    {
      $watch = $1;
      $term->{activity_ov} = $term->overlay_simple(-1, 0, $watch);

      if($watch eq 'inactivity')
      {
        $term->{inactivity_timer} = urxvt::timer
        -> new
        -> after(2)
        -> cb(sub
          {
            $term->scr_bell;
            $watch = "";
            delete $term->{activity_ov};
            delete $term->{inactivity_timer};
          });
      }
    }
  }

  ()
}

sub on_add_lines
{
  my ($term) = @_;

  if($watch eq 'activity')
  {
    $term->scr_bell;
    $watch = "";
    delete $term->{activity_ov};
  }
  elsif($watch eq 'inactivity')
  {
    $term->{inactivity_timer}->after(2);
  }

  ()
}
