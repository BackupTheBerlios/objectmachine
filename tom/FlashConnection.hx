
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

  This class is used by the flash client to connect to a remote
  world. It inherits from Connection which does most of the work.

*/

package tom;

class FlashConnection extends Connection
{   
   public function new(debug : Bool)
   {
      super(debug);
   }

   public function setSocket(socket : flash.net.Socket)
   {
      this.socket = socket;
   }

   public override function connect(host : String, port : Int)
   {
      try
      {
         this.socket.connect(host, port);
      }
      catch (e : Dynamic)
      {         
         if (!this.blocking(e)) trace(e);
      }
   }

   public override function close()
   {
      this.socket.close();
   }

   
   private var socket : flash.net.Socket;

   private override function writeByte(byte : Int)
   {
      this.socket.writeByte(byte);
   }

   private override function writeChar(string : String)
   {
      this.socket.writeByte(string.charCodeAt(0));
   }

   private override function flush()
   {
      this.socket.flush();
   }

   private override function dataAvailable() : Bool
   {
      return (this.socket.bytesAvailable > 0);
   }
   
   private override function readByte() : Int
   {
      return this.socket.readByte();
   }

   private override function readChar() : String
   {
      return String.fromCharCode(this.socket.readByte());
   }
}
