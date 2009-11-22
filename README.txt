= ICB

* http://github.com/dsully/ruby-icb

== DESCRIPTION:

Port of Perl's Net::ICB module for accessing the Internet Citizen's Band chat server protocol.

== FEATURES/PROBLEMS:

ICB exists at all!

== SYNOPSIS:

icb = ICB.new({ :user  => "foo", :group => "somegroup", :log => @logger })

loop do
    type, chat = icb.readmsg
    from, msg = *chat

    # process messages
    if private
        icb.sendpriv(to, message)
    else
        icb.sendopen(message)
    end
end

== REQUIREMENTS:

* Ruby 1.8.5 or above.

== INSTALL:

* sudo gem install

== LICENSE:

(The MIT License)

Copyright (c) 2008-2009 Dan Sully

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
