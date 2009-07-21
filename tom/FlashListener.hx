
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

  The Listener class.

*/

package tom;

class Listener extends Object, implements Runnable
{
   public function new()
   {
      super();

      this.words.set("listen", Reflect.field(this, "listen"));
   }
    
   public function run(steps : Int)
   {
      if (!this.connected)
      {
         // No connection request in progress
         // Get a new one if available
         try
         {
            this.connectedSocket = this.listenSocket.accept();
            this.connectedSocket.setBlocking(false);
            this.connected = true;
         }
         catch (e: String)
         {
            if ("Blocking" == e) return;
            trace(e);
         }
      }

      // A new connection has arrived

      // Read from it to determine the name of the network
      // object to create This can be slow so do it in
      // chunks. Include some sort of timeout (short) to give
      // others a chance

      // First comes the length of the message

      // Then comes the message

      // Create a message from the received text

      // Execute the message body

      // Send a message to the local world asking it to create
      // a network component named according to the name in the
      // message the name in the message is the name of the
      // remote world domain the connection is coming from
        
      // Send a message to the new network component containing
      // the serialized new socket

      this.connected = false;
   }

   // Private

   // Word

   private function listen()
   {
      var host = this.stack.pop();
      var port = this.stack.pop();

      this.listenSocket = new Socket();
      try
      {
         this.listenSocket.bind(new neko.net.Host(host), port);
         this.listenSocket.listen(10);
         this.listenSocket.setBlocking(false);
      }
      catch (e : Dynamic)
      {
         trace(e);
      }
   }
}
