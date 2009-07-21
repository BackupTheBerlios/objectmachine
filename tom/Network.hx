
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

  The Network class.

*/

package tom;

class Network extends Object
{
   public function new(world : World)
   {
      super(world);

      this.connectionInitialized = false;
      this.initSent = false;
      this.initReceived = false;
      this.ready = false;
      
      this.words.set("connect", Reflect.field(this, "connect"));
      this.words.set("destroy", Reflect.field(this, "destroy"));

      if (this.debug) trace("Network created");
   }

   public function setConnection(conn : Connection)
   {
      this.conn = conn;
   }
   
   public override function run(steps : Int)
   {
      super.run(steps);

      this.ready = (this.conn.connected &&
                    this.connectionInitialized);
      
      this.checkMessages();
      if (this.okToConnect && !this.conn.connected)
      {
         this.conn.connect(this.host, this.port);
      }
      if (!this.connectionInitialized) this.initConnection();
   }

   
   // Private

   var conn : Connection;
   var connectionInitialized : Bool;
   var initSent : Bool;
   var initReceived : Bool;
   var host : String;
   var port : Int;
   var okToConnect : Bool;
   var ready : Bool;
   
   private function initConnection()
   {
      if (!this.conn.connected) return;
      if (this.debug) trace("initializing the connection");
      this.sendInit();
      this.receiveInit();
      this.connectionInitialized = (this.initSent &&
                                    this.initReceived);
      if (this.debug)
      {
         if (this.connectionInitialized)
            trace("connection initialized");
      }
   }
   
   private function sendInit()
   {
      /*
        The remote network component should be named like the
        name of the local domain since it will route messages
        over here. Create a script that will name it accordingly
        and send it over.
      */
      if (!this.initSent)
      {
         if (this.debug) trace("sending init script");
         if (this.conn.textSent)
         {
            this.world.execute("getdomain");
            var script = this.world.pop() + " name";
            if (this.debug) trace("init script is " +
                                  "'" + script + "'");
            this.conn.setText(script);
         }
         this.conn.send();

         if (this.conn.textSent)
         {
            if (this.debug) trace("init script sent");
            this.initSent = true;
         }
      }
   }

   private function receiveInit()
   {
      /*
        The remote end should send over the name of its local
        domain (the above sendInit function). The name received
        will be the name of this component. This works since the
        Listener is still holding this component, preparing it
        for being run in the world.
      */
      if (!this.initReceived)
      {
         if (this.debug) trace("receiving init script");
         this.conn.receive();
         if (this.conn.textReceived)
         {
            var script = this.conn.getText();
            if (this.debug) trace("init script received is " +
                                  "'" + script + "'");
            this.execute(script);
            this.initReceived = true;
         }
      }
   }
   
   private override function checkMessages()
   {
      if (this.debug) trace("checking messages");

      this.sendWaiting();
      this.forwardReceived();
   }

   private function sendWaiting()
   {
      var message = this.peekMessage();
      if (null == message) return;  // Nothing to send
      var receiver = message.getReceiver();
      if (StringTools.endsWith(receiver, this.name))
      {
         // The message is to me
         if (this.debug) trace("reading message");
         message = this.receiveMessage();
         this.execute(message.body);
      }

      if (!this.ready) return;

      if (this.conn.textSent)
      {
         message = this.receiveMessage();
         if (null == message) return;
         var text = message.headerBodyCombined;
         this.conn.setText(text);
         if (this.debug) trace("sending text " +
                               "'" + text + "'" +
                               " over the network");
      }
      this.conn.send();
   }

   private function forwardReceived()
   {
      if (!this.ready) return;

      if (this.connectionInitialized)
      {
         this.conn.receive();
         if (this.conn.textReceived)
         {
            var message = new Message();
            var text = this.conn.getText();
            if (this.debug) trace("received text " +
                                  "'" + text + "'" +
                                  " from the network");
            message.execute(text);
            this.sendMessage(message);
         }
      }
   }

   // Word

   private function connect()
   {
      this.host = this.stack.pop();
      this.port = Std.parseInt(this.stack.pop());
      this.okToConnect = true;
      this.conn.connect(this.host, this.port);

   }

   private function destroy()
   {
      this.conn.close();
   }
}
