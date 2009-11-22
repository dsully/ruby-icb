class ICB
  require 'socket'
  require 'logger'

  VERSION = "1.0.1"

  # Port of Perl's Net::ICB by Dan Sully

  # Default connection values.
  # (evolve.icb.net, empire.icb.net, cjnetworks.icb.net, swcp.icb.net)
  DEF_HOST  = "default.icb.net"
  DEF_PORT  = 7326
  DEF_GROUP = 1
  DEF_CMD   = "login"  # cmds are only "login" and "w"
  DEF_USER  = ENV["USER"]

  # Protocol definitions: all nice cleartext.
  DEL        = "\001"  # Packet argument delimiter.
  M_LOGIN    = 'a'           # login packet
  M_LOGINOK  = 'a'     # login response
  M_OPEN     = 'b'     # open msg to group
  M_PERSONAL = 'c'     # personal message
  M_STATUS   = 'd'     # group status update message
  M_ERROR    = 'e'     # error message
  M_ALERT    = 'f'     # important announcement
  M_EXIT     = 'g'     # quit packet from server
  M_COMMAND  = 'h'     # send a command from user
  M_CMDOUT   = 'i'     # output from a command
  M_PROTO    = 'j'     # protocol/version information
  M_BEEP     = 'k'     # beeps
  M_PING     = 'l'     # ping packet from server
  M_PONG     = 'm'     # return for ping packet
  # Archaic packets: some sort of echo scheme?
  M_OOPEN    = 'n'     # for own open messages
  M_OPERSONAL= 'o'     # for own personal messages

  attr_reader :debug

  # Create a new fnet object and optionally connect to a server.
  # keys: host port user nick group cmd passwd
  def initialize(options = {})

    if options[:log]
      @log = options[:log]

      if options[:debug]
        debug = true
      end
    end

    connect(options) unless options.empty?
  end

  def debug=
    @log.level = Logger::DEBUG
  end

  # Open or group wide message.
  def sendopen(txt)
    sendpacket("#{M_OPEN}#{txt}")
  end

  # Private or user-directed message.
  def sendpriv(nick, msg)
    sendcmd("m", nick, msg)
  end

  # Server processed command.
  # sendcmd(cmd, args)
  def sendcmd(cmd, *kwargs)
    sendpacket("#{M_COMMAND}#{cmd}#{DEL}#{kwargs.join(' ')}")
  end

  # Ping reply.
  def sendpong
    sendpacket(M_PONG)
  end

  # Send a raw packet (ie: don't insert a packet type)
  def sendraw(buf)
    sendpacket(buf)
  end

  # Read a message from the server and break it into its fields.
  # XXX - timeout to prevent sitting on bad socket?
  def readmsg
    # Break up the message.
    type, buf = recvpacket.unpack("aa*")

    sendpong if type == M_PING

    return type, buf.split(DEL)
  end

  # Connect to a server and send our login packet.
  # keys: host port user nick group cmd passwd
  def connect(options)
    @options = options
    @host    = options[:host]  || DEF_HOST
    @port    = options[:port]  || DEF_PORT

    @log.debug "Connecting to #{@host}:#{@port}"

    @socket  = TCPSocket.new(@host, @port)
    sendlogin
  end

  def close
    if @socket
      @socket.close
    end
  end

  private

  # Sends a login packet to the server.  It specifies our login name,
  # nickname, active group, a command "login" or "w", and our passwd.
  def sendlogin
    user   = @options[:user]  || DEF_USER
    nick   = @options[:nick]  || user
    group  = @options[:group] || DEF_GROUP
    cmd    = @options[:cmd]   || DEF_CMD
    passwd = @options[:passwd]

    sendpacket(M_LOGIN + [user, nick, group, cmd, passwd].join(DEL))

    @user = user
  end

  # Send a packet to the server.
  def sendpacket(packet)
    @log.debug "SEND: #{packet.size+1}b -- #{packet}\\0"

    # Bounds checking to MAXCHAR-1 (terminating null).
    if packet.size > 254
      raise RuntimeError, "send: packet > 255 bytes"
    end

    # Add the terminating null &  packet length (<= 255) to the packet head.
    packet << "\0"
    packet = packet.size.chr + packet

    wrotelen = @socket.send(packet, 0)

    if wrotelen != packet.size
      raise RuntimeError, "send: wrote $wrotelen of $plen: $!"
    end
  end

  # Read a pending packet from the socket.  Will block forever.
  def recvpacket
    buffer = ""

    # Read a byte of packet length. [0] converts to ord.
    slen = @socket.recv(1)[0]

    while (slen > 0)
      ret = @socket.recv(slen)

      raise RuntimeError if ret.nil?

      slen -= ret.size
      buffer << ret
    end

    @log.debug "RECV: #{buffer.size}b -- #{buffer}"

    buffer.chop
  end
end
