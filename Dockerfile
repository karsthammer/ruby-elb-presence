FROM dockerfile/ruby

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
CMD bundle install

ADD elb-presence.rb /bin/elb-presence

CMD ["bundle", "exec", "/bin/elb-presence"]
