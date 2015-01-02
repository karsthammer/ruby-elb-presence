FROM dockerfile/ruby

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
CMD bundle install

ADD elb-presence.rb /bin/elb-presence

CMD /bin/elb-presence
