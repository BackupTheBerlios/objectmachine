
/*

  Copyright 2009 The Object Machine Project. All rights
  reserved.

  Redistribution and use in source and binary forms, with or
  without modification, are permitted provided that the following
  conditions are met:

  1. Redistributions of source code must retain the above
     copyright notice,  this list of conditions and the following
     disclaimer.
  2. Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following
     disclaimer in the documentation and/or other materials
     provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE OBJECT MACHINE PROJECT ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
  SHALL THE OBJECT MACHINE PROJECT OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  OF SUCH DAMAGE.

  The views and conclusions contained in the software and
  documentation are those of the authors and should not be
  interpreted as representing official policies, either expressed
  or implied, of The Object Machine Project.

*/

/*

  This class is used by the worlds run by neko to connect to a
  remote worlds run on other servers. This connection is not used
  to connect flash clients to the world. Use NekoFlashConnection
  for that.
  Inherits from Connection which does most of the work.

*/

package tom;

class NekoConnection extends Connection
{
   public function new(?debug : Bool = false)
   {
      super(debug);
   }

   public override function connect(host : String, port : Int)
   {
      try
      {
         /*
           Connecting in non-blocking mode is not working very
           weill - switch to blocking mode temporarily while
           connecting. Recycle socket if it fails.
         */
         if (this.debug)
            trace("connecting to " + host + ":" + port);
         if (null == this.socket)
            this.setSocket(new neko.net.Socket());
         this.connected = false;
         this.socket.setBlocking(true);
         this.socket.setTimeout(1);
         this.socket.connect(new neko.net.Host(host), port);
         this.socket.setBlocking(false);
         this.connected = true;
         if (this.debug)
            trace("connected to " + host + ":" + port);
      }
      catch (e : Dynamic)
      {
         if (!this.blocking(e))
         {
            this.setSocket(new neko.net.Socket());
            this.connected = false;
            trace(e);
         }
      }
   }

   public function setSocket(socket : neko.net.Socket)
   {
      this.socket = socket;
      this.socket.setBlocking(false);
      // Assume this socket is connected
      this.connected = true;
   }
   
   public override function close()
   {
      try
      {
         this.socket.close();
      }
      catch (e : Dynamic)
      {
      }
      
      this.connected = false;
   }

   
   private var socket : neko.net.Socket;

   private override function writeByte(byte : Int)
   {
      // This seems to be buggy when used on non-blocking sockets
      // Does not resume when blocked on buffer full (after 255
      // calls)
      this.socket.output.writeByte(byte);
   }

   private override function writeChar(string : String)
   {
      this.socket.output.writeString(string);
   }
   
   private override function flush()
   {
      this.socket.output.flush();
   }
   
   private override function dataAvailable() : Bool
   {
      return true;
   }
   
   private override function readByte() : Int
   {
      // This seems to be buggy when used on non-blocking sockets
      // Does not resume when blocked on buffer full
      return this.socket.input.readByte();
   }

   private override function readChar() : String
   {
      return this.socket.input.readString(1);
   }
}
