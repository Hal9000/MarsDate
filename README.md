# MarsDate
##   A Ruby date/time library for Mars

This library is based on the Martian Common Era calendar by Hal Fulton.
Its functionality closely follows that of Ruby's Time class.

### The Martian Common Era calendar

Read more about this below.

### More to come...

What needs doing here:
  - Restructure the project tree
  - Change tests from shoulda to rspec
  - Clean up the source
  - Add some executables (mcal, etc.)
  - Add extensive documentation to this README
  
<html>
<title>The Martian Common Era Calendar</title>
<body>

<center>
<h2>The Martian Common Era Calendar</h2>
<br>
by Hal E. Fulton
<br>
<br>
</center>

<p>
It may seem odd, but people have been designing Martian calendars
for over a century now, despite the fact that not even one human
has set foot there yet. By one count, over <i>seventy-five</i> 
different calendars have been created for the red planet. One 
reason for this, of course, is that it's a challenging and fun 
problem.

<p>
But it goes beyond that. We are closer than ever to a human presence
on Mars; and it is never too early to think about such details.

<p>
In this "me too" spirit, I give you the <i>Martian Common Era</i>
calendar (MCE). Like many, it is a variant of Darian Calendar of 
Thomas Gangale, perhaps the best known calendar for Mars.

<p>
The purpose for this particular calendar, however, is more than just
a proposal for later use. It's also for fun. Want to celebrate the
Martian New Year? You can, if you and your friends agree on when it
is. Want to celebrate your Martian birthday? Those are special because
they are twice as rare as regular birthdays.

<p>
The purpose of this article isn't to give exhaustive technical details.
If you are interested in Martian calendars, I can refer you to the 
work of Thomas Gangale (mentioned previously). Others have done 
interesting work as well &mdash; a web search will give you a wealth of
material within minutes.

<p>
Bear in mind when I talk in this article about "Earth's calendar," I am
being a little unfair. We have had many different calendars in our history,
and there are different ones in use even today. The calendar I refer to as 
the "Earthly" calendar is of course the Gregorian, probably the nearest 
thing to a universal calendar that humans have ever had.

<p>
I'll give you just a little background information here. Consider this
a short introduction to Mars and to calendars in general.

<p>
Mars is farther out from the sun than the earth is, and so it travels
around the sun more slowly. In fact, a Martian year is nearly twice as
long as one of ours &mdash; twenty-three of our months, give or take a little.

<p>
The Martian day, on the other hand, is very nearly the same as an earthly
day &mdash; roughly 24 hours and 39 minutes. A day on Mars is called a 
<i>sol</i> (as in <i>solar</i>)to distinguish it from an earthly day. This
usage came about in the 1970s when NASA first placed a lander on the Martian
surface; the scientists on the Viking lander team naturally needed to talk
about the "day and night" patterns of the world they were studying.

<p>
There are some people who want to use alternate terms for a Martian year. 
These terms include <i>mir</i> and <i>orb</i> (as in <i>orbit</i>). Others, 
like me, are content to say "year" both for Earth and for Mars (and may 
sometimes disambiguate by saying "Martian year," "Mars year," "M-year," 
or something similar).

<p>
One thing that makes calendars hard (even on Earth) is that the year is not
made up of an exact number of days. When the Earth orbits for a full 365
days, it is still almost 6 hours short of going all the way around the sun.
That, of course, is why we add a leap year roughly every four years.

<p>
Mars, on the other hand, orbits the sun in about 687 earth days or 668 sols.
But again, when the 668 sols have passed, there is still a fraction of a sol
left before it goes all the way around the sun. In this case, the fraction 
is nearer to a half, so it makes sense for a Martian calendar to have a leap
year almost every other year.

<p>
So these facts are pretty much beyond our control. Things that are more within
our control are: Where do we start counting? How do we group the days together
into months, and what do we name them? Do we keep a seven-day week? Where do 
we put the leap day when we need it? 

<p>
First, let's look at the question of where the year starts. On Earth, the day
most of us call "January 1" is considered to be the first day of the year. 
To understand why is beyond the scope of this article. Suffice to say that it
has more to do with history, religion, and politics than it has to do with 
astronomy or any other science. 

<p>
On Mars, we could pick any day to be the start. One <i>logical</i> choice might
be the first day of spring; after all, we think of spring as a time of "new
beginnings" and so on. As a matter of fact, this choice is widespread among
planetary scientists (for Mars and for other planets as well). In addition, most
Martian calendars have made that same decision. So let's stick with that.

<p>
The astute reader may ask: <i>Which</i> vernal equinox? After all, the northern
hemisphere's vernal (or spring) equinox is the same as the southern hemisphere's
autumnal (fall) equinox. But here, as in many things, there is an arbitrary 
convention; we assume that the <i>northern</i> hemisphere is the standard. When
we draw a typical diagram of the solar system, we are looking downward onto the
Sun's north pole (and that of the Earth and Mars as well). So the first day of
the Martian year will be the spring equinox in the northern hemisphere, but the
<i>fall</i> equinox in the southern hemisphere.

<p>
Next let's look at the question of months. We divide time on Earth into months
because that is roughly the length of the lunar cycle. (Of course, once again
Nature does not cooperate &mdash; the number of lunar months in a year is not 
exactly twelve.)

<p>
But on Mars, Earth's lunar cycle is pretty meaningless. Yet we have grown used to
the convenience of dividing a year into months &mdash; a period much larger 
than a day but much smaller than a year.

<p>
It's not <i>necessary</i> to divide a year into months at all, of course. One 
possible Martian calendar would just number the days from 1 to 668 (or 669 in a 
leap year). This has the virtue of simplicity, but it does sound rather boring.
To date a letter "Day 226" makes it sound like an entry from a prisoner's diary.
Birthdays would also sound boring &mdash; "My birthday is 348, and hers is 529."
Very practical, maybe, but not much fun.

<p>
It's tempting to look to the moons of Mars as a way of dividing a year into 
months. Unfortunately, these are much smaller than ours and orbit much more 
closely &mdash; so they move very fast. The outer moon Deimos goes around Mars 
in less than a day and a half. The inner moon Phobos actually orbits in less 
than 8 hours. So they're completely unsuitable for this purpose.

<p>
The usual approach is to make the months more or less arbitrary. Some Martian 
calendars have divided the year into 12 months (as we are accustomed to); the 
disadvantage is that the months then have more than 50 days each, much more 
than we are used to. The other common choice is 24 months that are very near in 
length to our earthly months. One problem then, of course, is naming the months. 

<p>
At least one calendar has actually compromised on a sixteen-month year, with 
each month being 40-something days in length. This is an interesting and 
innovative approach, but it doesn't appeal to me so much.

<p>
So I decided to go the "conventional" route and have 24 months. The next 
question obviously is: How do we name them? 

<p>
Some have suggested a scheme where there is a "First January" and a "Second 
January" (and so on for all the months). Others have suggested elaborate 
culturally-neutral naming schemes.

<p>
My choice was to use the conventional twelve month names and intersperse the 
names of the signs of the zodiac. This solution is not "culturally neutral" as 
such; but virtually every language in the world has names for the twelve months 
and the twelve signs. For me, that is close enough.

<p>
So I start with the usual "January" and then follow with Gemini. Why Gemini, 
you may ask? Well, if you view the solar system as a clock with the sun at the 
center, the constellations are arranged around it so that Mars is "in" Gemini 
at the time of its vernal equinox. 

<p>
This, by the way, is a <i>heliocentric</i> or sun-centered viewpoint. It is 
therefore 180 degrees opposite to the approach followed by ancient astronomers, 
who thought according to an Earth-centric standard, calculating in which 
constellation the sun fell. By that kind of thinking, Martians would see the 
sun in Sagittarius at their vernal equinox, so we could name that month 
Sagittarius; but now that we know that the planets orbit the sun (not the 
Earth!), let us think and act accordingly.

<p>
By now, you may be thinking of the old rhyme, "Thirty days hath September..." 
How many days should each Martian month have?

<p>
There is more than one way to partition them, of course. We could adjust them 
so that they fit the Martian seasons; these are "lopsided" or irregular because 
of the highly elliptical orbit Mars has.

<p>
I prefer a simpler approach. Let's give each of them 28 days. The exception, of 
course, will be the final month of Taurus, which will have only 24 (giving a 
total of 668 sols). When there is a leap year, I would add the day naturally to 
the end of the year, giving Taurus a 25th day (rather than adding to the end of 
the second month as we do on Earth).

<p>
Wait a minute! Leap years? Yes, as I mentioned before, they are an issue on 
Mars &mdash; more so than on Earth, in fact.

<p>
You may think leap years in our Earthly calendar are "easy." In a sense, they 
are. But there are more rules than most people realize!

<p>
The Earth orbits the sun in roughly 365.2422 days &mdash; the leftover 0.2422 
days, of course, is why we have leap years. In four years, we accumulate 0.9688 
days, which is very nearly an entire day, so we add a day to "re-synchronize." 
So far, it's easy.

<p>
But this is a little too much correction. We've over-corrected by about 0.03 
days (or about 42 minutes). So the next rule is: When the year is a multiple of 
100 (like 1800 or 1900), we will <i>skip</i> a leap year. I won't do the math, 
but this results in a slight under-correction. We then add yet another rule: If 
a century year (a multiple of 100) is <i>also</i> a multiple of 400, then it 
<i>will</i> be a leap year. This is why 1800 and 1900 were not leap years, but 
2000 was. 

<p>
The bad news is, Martian leap years will be just as complex. The good news is, 
we can manage that complexity much the way we do with our Earthly calendar.

<p>
I'll spare you the math. We'll use the same scheme Thomas Gangale used with his 
Darian calendar. Essentially, each decade will have six leap years and four 
non-leap years; the leap years will have 669 sols and the others will have 668.

<p>
As a side note: We are accustomed to leap years occurring fairly rarely &mdash; 
but in this calendar, leap years are actually <i>more common</i> than non-leap
years. For this reason, I recommend introducing the more intuitive terms "short
year" and "long year." A <i>long year</i> is then the same as a leap year, of
course.

<p>
The easy way to allocate these leap years is to say: Odd numbered years have an 
odd number of days (669), and even-numbered years will have an even number of 
days (668). Since this is only five leap years per decade, we will add the rule 
that a multiple of 10 is a leap year.

<p>
To make the math come out better, we'll have to add two more rules: A century 
year (multiple of 100) is <i>not</i> a leap year, whereas a millennial year 
(multiple of 1000) <i>is</i> a leap year.

<p>
This raises yet another question: How do we number the years? In calendar 
jargon: When is our <i>epoch</i>? On Earth, we number according to a scheme 
devised by a medieval monk who tried to estimate the birth year of Jesus, using 
that for Year 1. (Most authorities believe he was off by at least four years.) 
This is the Common Era, now commonly abbreviated "C.E." (as in 2010 C.E.); for 
centuries, of course, the abbreviation was "A.D." (<i>Anno Domini</i> or "the 
year of our Lord").

<p>
For Mars, there are several logical choices. One common suggestion has been to 
use the date of the first robotic landing on Mars (by the Viking lander, in 
1976). This has the disadvantage that many common dates (such as the year of 
someone's birth or some twentieth century event) might be negative dates. As of 
early 2009, it has been roughly eighteen Martian years since Viking landed.

<p>
Another choice, used in the Darian calendar, is to mark the first year that 
Mars was observed in a telescope, the year we call 1609. In this system, the 
Earthly year 2008 would roughly correspond to (or overlap) the Martian year 212.

<p>
The choice I made was to anchor the Martian epoch as close to our accustomed 
one as possible (hence the name "Martian Common Era"). As it happens, Mars had 
a vernal equinox about three weeks into January of the year we call the Year 1. 
(Our calendar has no Year 0, which explains why the 21st century actually began 
on January 1, 2001).

<p>
So let's call this early equinox the Martian epoch. Choosing the epoch near our
accustomed one gives the Martian calendar a moderately interesting property: If 
you take the ratio of the Earthly and Martian year numbers, you will get a 
familiar ratio. It is 1.88 &mdash; the same as the ratio of the length of a 
Martian year to the length of an Earthly year. If you think about this for a 
moment, it becomes obvious. While Mars orbits the sun 100 times, the Earth will 
orbit the sun about 188 times.

<p>
This, of course, makes it possible to quickly estimate a Martian year from an
Earthly one, or vice versa. Since Mars orbits the sun in 1.88 of our years,
the Martian year 1000 would be approximately our year 1880.

<p>
So we know where our calendar starts and where each year starts. We know the 
names of the months and how long each year is. We know when the leap years are.

<p>
One question we haven't asked is: How do we deal with days of the week?

<p>
Again, there are multiple possibilities. One possibility is to forget them 
altogether &mdash; throw away the idea of a "week" as a division of time. But 
in nearly all countries and cultures, we have been used to them for a long time.

<p>
Another possibility is to use a week that is some length other than 7 days (or 
sols in this case). This is not unheard of even in Earthly calendars; but 
again, most people worldwide, in recent centuries, recognize a seven-day week.

<p>
Some Martian calendars use weeks of seven sols or other lengths. Most of them 
use sophisticated or colorful naming systems for the sake of cultural 
neutrality, novelty, or other reasons.

<p>
In keeping with my theme of simplicity and intuitiveness, I have decided to 
keep the "normal" seven-day cycle. Likewise, I will keep the ordinary names, 
which after all may be translated into many different languages.

<p>
Some Martian calendars have the days of the week fixed with respect to the 
year. That is, the year always starts on the same day of the week; and thus 
(for example) the 20th day of the third month will always be the same day of 
the week from year to year.

<p>
This is appealing in many ways. But personally I have two small issues with it; 
first of all, the end of the year introduces a "jump" where, for example, a 
Wednesday on the last day of the year might be followed immediately by a Sunday 
on the first day of the next year. I find the discontinuity to be a little 
jarring.

<p>
Second of all &mdash; and some will disagree &mdash; I don't entirely like the 
concept of a date occurring on the same weekday every year. I find it to be a 
little boring.  Do you want your birthday to fall on Monday <i>every year</i>? 
Should New Year's Day (or the first sol of spring) <i>always</i> be on a 
Sunday? Let's have some variety instead. Let's start the cycle at some known 
point and let it stretch forward and backward, the seven-day cycle running 
independently of the rest of the calendar, more or less as it does on Earth.

<p>
Of course, the Martian Common Era calendar <i>does</i> offer a few small 
advantages in that respect. Notice that each month (except the last one) is 28 
days long, which is a multiple of 7. This means that the first of each month 
will be the same day of the week for the entire year. If January 1 starts the 
year off on a Tuesday, then Gemini 1, February 1, and all the others will also 
fall on a Tuesday. In fact, each month except Taurus will have the same pattern 
of weekdays all year long. (Even Taurus will follow that pattern until it runs 
out of days.)

<p>
Let's look at terminology a little further. Obviously there is some ambiguity
if we don't specify which calendar or planet we are talking about. If I say 
"the month of Gemini," it's clear I mean Mars; but if I say "the month of 
April," it is unclear. For that reason, I suggest the convention of an 
optional "M" with a hyphen to be used in front of a name, a unit, or a number 
as needed.

<p>
So I might say "Martian April" or "M-April"; I might refer to "20 M-years" 
(meaning 37 Earthly years). I might refer to "the M-year 1071" or even "the
year M-1071"; however, in the case of years, context will usually be enough to
distinguish the two. To be formal about year, we can always say "the year
1071 MCE."

<p>
So given what we have so far, we can calculate that this past New Year's Day,
(January 1, 2010) was the Martian date Tuesday, M-February 11, 1069 MCE.
For another example: July 4, 2011 would be Thursday, the 13th of Aries (still
in M-year 1069). The next Martian New Year (January 1, 1070 MCE) will be on
September 13, 2011.

<p>
But be aware that I'm cheating when I say that some Earthly date is "the same"
as some Martian date. After all, even on Earth we don't agree on what day it 
is &mdash; for people in the USA, it's already "tomorrow" in some other parts
of the world. In reality, a Martian date <i>overlaps</i> with an Earthly date.
The crude conversion that I use is to take the beginning point of the date in 
one calendar and ask: In what day (in the other calendar) does this timepoint 
fall? But if you take into account timezones on Earth (and on Mars!), you will 
occasionally disagree by a day.

<p>
A natural question is: What holidays might be associated with this kind of 
calendar? Well &mdash; we can't predict what religious or civil significance
(if any) may be attached to various dates on Mars. I assume that when there are
humans on Mars, they will take care of such matters as they arise, regardless
of what calendar they use. 

<p>
Take Christmas, for example. Conceivably we could pick a date in history and
translate it to the Martian reckoning; but what date would we use? Our 
December 25 falls on a different Martian day each M-year. Furthermore, we have
never been certain of the year of the birth of Jesus, much less the exact date.
(December 25 is purely a convenient fiction &mdash; the date was taken from
the old Roman holiday of Saturnalia as a matter of convenience.)

<p>
So let's ignore things such as Christmas and Ramadan, as well as the numerous
other holidays such as Thanksgiving and Mother's Day. This still leaves two
categories of holidays we might celebrate &mdash; those based on astronomy and
those based on modern events relating to Mars.

<p>
For example, celebrating the new year and celebrating the spring equinox are
human traditions that have been observed in countless cultures for thousands
of years. In this calendar, we kill two birds with one stone, as they are the
same day (unless you are in the Martian southern hemisphere).

<p>
Earth will be the "real home" of mankind for quite some time in the future.
Therefore any notable relationship between the planets in their orbits will be
a cause for observance on Mars. I expect a "Conjunction Day" when the planets
are across the sun from each other; and an "Opposition Day" when they are 
aligned on the same side of the sun. These will be a matter of practical 
concern, as communication with Earth will be easiest as we approach opposition,
and will be more difficult or impossible at conjunction. They will also add
variety to life, as they will occur fairly rarely and irregularly &mdash; not
on a trivially predictable day. Thus they will "float" through the calendar,
more like Easter than Christmas.

<p>
I can imagine that "Viking Day" might be celebrated on Mars. The Viking lander
was the first successful landing by a probe on Mars on July 20, 1976 (which
itself was the anniversary of the Apollo 11 moon landing). This corresponds
to the date Virgo 12, 1051 MCE (which was a Martian Tuesday).

<p>
It might make sense to celebrate the winter solstice on Mars, as every culture
on Earth does. Although it won't matter <i>quite</i> as much as on ancient
Earth, seasonal variations will still affect the Martian settlers.

<p>
Another big day might be the anniversary of the first human landing on Mars
&mdash; certainly a day worth celebrating hundreds of years into the future! 
But of course, we don't know yet when that day will be.

<p>
But what about Martian versions of Earthly holidays? Will there ever be a 
Martian Thanksgiving or Halloween or any of those? Only time will tell.

<p>
So far, we've discussed the calendar, but not timekeeping in terms of hours and
minutes. There are two or three way of dealing with Martian time.

<p>
One school of thought says: Forget tradition; let's institute a totally new
method of timekeeping. And there is some appeal to this. Most of our 
measurements in modern times are "metric" or base-10 systems. Some have
suggested dividing the day into 1,000 divisions that are like minutes (or
100,000 that are like seconds). Such units might be called "ticks" or "beats"
or other similar names; specifying a time of day might be as simple as 
naming an integer, such as, "The time is now 592." Overall, however, this
is too complex for my taste. It introduces totally new terminology and a new
set of arbitrary units, and it's completely incompatible with what we're
used to.

<p>
Another approach was taken by Kim Stanley Robinson in his Mars trilogy. In
these novels, the Martian settlers measured time as we do from midnight to
midnight -- but the extra 39 minutes were "off the clock." Time, in effect,
"stopped" during the timeslip, which they used for relaxation or celebration.
This is an entertaining solution, and my own concept is very similar.

<p>
The nearest thing we have to an "official" clock for Mars is the one used
by many NASA scientists -- what is sometimes called <i>stretched time.</i>
Because the Martian day is so near our own, it makes sense to divide it
into 24 hours (each of which is about 4% longer than ours). So each 
"stretched" hour is made up of 60 "stretched minutes" each of which is
60 "stretched seconds." So this clock goes from midnight to midnight just
as we're accustomed to.

<p>
One small problem with stretched time is that our common units now have
different values. We use seconds and minutes to measure duration all the
time; it's undesirable to have two separate standards for those (even
though the difference is a little less than 3 percent).

<p>
What I propose is that we keep our usual hours, minutes, and seconds. We
simply let the clock run longer (similar to Robinson's solution). So the
day would start at 0:00 and run until roughly 24:39:35 (plus about a
quarter of a second). If you're staring at the clock at the exact end of
day, you will see a slight hesitation (or your clock will fall behind by 
a fraction of a second).

<p>
This brings us to the issue of time zones. These can certainly be set up
similarly to what we have on Earth, or we could dispense with them entirely.
The Martian equivalent of Greenwich, by the way, is a little crater named
<i>Airy Zero</i>, inside Airy Crater, naturally located on the prime 
meridian, zero longitude.

<p>
At this point, someone will wonder about Daylight Saving Time. In my opinion,
if there is one thing we could leave behind on Earth, this is it. (Even 
discontinuing the practice on Earth might not be a bad idea.)

<p>
If we settle Mars, we will have countless challenges and opportunities 
before us. Worrying about clocks and calendars will be only one of thousands
of issues we have to face. So we do little projects like this one.  It is 
wise, or at least fun, to take care of what we can ahead of time.

</body>
</html>

