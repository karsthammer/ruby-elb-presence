FROM dockerfile/ruby

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
CMD bundle install

ADD elb-presence /bin/elb-presence

CMD /bin/elb-presence
