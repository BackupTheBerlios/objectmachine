
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

  This class implements the send and receive part of the network
  connections used by the listener and network components.
  To use it, the read and write methods need to be implemented by
  inheriting from this class and overriding the functions. See
  NekoConnection and FlashConnection for examples.

*/

package tom;

class Connection
{
   public var connected(default, null) : Bool;
   public var closing : Bool;

   public var testSentCount : Int;
   public var testReceivedCount : Int;

   public var textSent(default, null) : Bool;
   public var textReceived(default, null) : Bool;
   
   public function new(?debug : Bool = false)
   {
      this.debug = debug;
      
      this.textToSend = "";
      this.receiveBuffer = new StringBuf();
      this.textSent = true;
      this.textReceived = false;
      this.sendPos = 0;
      this.closing = false;
      this.connected = false;

      this.testSentCount = 0;
      this.testReceivedCount = 0;
   }

   public function connect(host : String, port : Int)
   {
   }
   
   public function setText(text : String)
   {
      this.textToSend = text;
      this.textSent = false;
      this.sendPos = 0;
   }

   public function getText() : String
   {
      this.receivedText = this.receiveBuffer.toString();
      this.receiveBuffer = new StringBuf();
      this.textReceived = false;
      return this.receivedText;
   }

   public function send()
   {
      if (this.textSent)  return;

      // Send at most 100 characters at a time
      var count : Int;
      for (count in 1...100)
      {
         if (!this.sendCharFromBuffer()) break;
      }
      this.flush();
    }

   public function receive()
   {
      if (this.textReceived)  return;

      // Receive at most 100 characters at a time
      var count : Int;
      for (count in 1...100)
      {
         if (!this.addCharToBuffer()) break;
      }
   }

   public function close()
   {
   }


   private var debug : Bool;
   private var textToSend : String;
   private var sendPos : Int;
   private var receivedText : String;
   private var receiveBuffer : StringBuf;
   
   private function addCharToBuffer() : Bool
   {
      try
      {
         if (!this.dataAvailable())  return false;
         var char = this.readChar();
         if (0 == char.charCodeAt(0))
         {
            this.textReceived = true;
            return false;
         }
         this.receiveBuffer.add(char);
      }
      catch (e : Dynamic)
      {         
         if (!this.blocking(e)) trace(e);
         return false;
      }
      return true;
   }

   private function sendCharFromBuffer() : Bool
   {
      try
      {
         if (this.sendPos == this.textToSend.length)
         {
            this.writeChar(String.fromCharCode(0));
            this.textSent = true;
            return false;
         }
          var char = this.textToSend.charAt(this.sendPos);
          this.writeChar(char);
          this.sendPos++;
      }
      catch (e : Dynamic)
      {         
         if (!this.blocking(e)) trace(e);
         return false;
      }
      return true;
   }
   
   private function blocking(e : Dynamic) : Bool
   {
      return ("Blocking" == e ||
              "Blocked" == e ||
              haxe.io.Error.Blocked == e);
   }
   
   private function writeByte(byte : Int)
   {
   }

   private function writeChar(string : String)
   {
   }
   
   private function flush()
   {
   }

   private function dataAvailable() : Bool
   {
      return false;
   }
   
   private function readByte() : Int
   {
      return 0;
   }

   private function readChar() : String
   {
      return "";
   }
}
