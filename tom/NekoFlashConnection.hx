
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
  remote worlds run by flash clients. To connect to worlds run on
  servers, use the class NekoConnection.
  Inherits from Connection which does most of the work.

*/

package tom;

class NekoFlashConnection extends NekoConnection
{
   public static var RECEIVINGREQUEST = 1;
   public static var SENDINGPOLICY = 2;
   public static var CLOSING = 3;
   
   public function new(socket : neko.net.Socket)
   {
      super(socket);
      
      this.initState = NekoFlashConnection.RECEIVINGREQUEST;
      this.policyFile = '<cross-domain-policy>' +
         '<allow-access-from domain="lap-jens" to-ports="*" />' +
         '</cross-domain-policy>';
   }

   public override function receive()
   {
      super.receive();
      
      switch (this.initState)
      {
      case Connection.RECEIVINGREQUEST:
         this.receivePolicyRequest();
      }
   }

   public override function send()
   {
      super.send();

      switch (this.initState)
      {
      case Connection.SENDINGPOLICY:
         this.sendPolicyFile();
      }
   }
   

   private var initState : Int;
   private var policyFile : String;

   private function receivePolicyRequest()
   {
      if (this.textReceived)
      {
         var text = this.getText();
         //trace("received " + text);
         if ("<policy-file-request/>" == text)
         {
            this.setText(this.policyFile);
            this.initState = NekoFlashConnection.SENDINGPOLICY;
         }
      }
   }

   private function sendPolicyFile()
   {
      if (this.textSent)
      {
         this.initState = Connection.CLOSING;
         this.closing = true;
      }
   }
}
