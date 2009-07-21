
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

class Listener extends Object
{
#if neko
   
   public function new(world : World)
   {
      super(world);
     
      this.connections = new List<Connection>();
      this.listenSocket = new neko.net.Socket();
      this.listenSocket.setBlocking(false);
      this.acceptingConnections = false;
      
      this.words.set("listen", Reflect.field(this, "listen"));
      this.words.set("destroy", Reflect.field(this, "destroy"));
   }
    
   public override function run(steps : Int)
   {
      super.run(steps);

      this.checkMessages();
      
      this.acceptConnection();
      this.serviceConnections();
   }

   // Private

   var listenSocket : neko.net.Socket;
   var connections : List<Connection>;
   var acceptingConnections : Bool;
   
   private function acceptConnection()
   {
      if (!this.acceptingConnections)  return;
      
      try
      {
         if (this.debug) trace("checking for a new connection");
         // Check if a new connection has arrived
         var socket = this.listenSocket.accept();
         if (this.debug) trace("new connection received");

         var conn = new NekoConnection(this.debug);
         conn.setSocket(socket);
         this.connections.add(conn);
      }
      catch (e: String)
      {
         if (!this.blocking(e))  trace(e);
      }
   }

   private function serviceConnections()
   {
      if (this.debug) trace("servicing " + connections.length +
                            " connections");
      var conn : NekoConnection;
      for (conn in this.connections)
      {
         try
         {
            this.writeConnection(conn);
            this.readConnection(conn);
            if (conn.closing)
            {
               this.close(conn);
            }
         }
         catch (e : Dynamic)
         {
            if (!this.blocking(e))  trace(e);
         }
      }
   }

   private function writeConnection(conn : Connection)
   {
      conn.send();
      if (conn.textSent)
      {
         // Don't have anything to send.
         // Could be used to send a rejection message to the
         // remote end. Then I also should not create the network
         // component in readConnection.
      }
   }

   private function readConnection(conn : Connection)
   {
      if (this.debug) trace("reading from connection");
      conn.receive();
      if (conn.textReceived)
      {
         /*
           Create a new network component, give it the
           connection  and allow it to configure itself by
           running it. It will finish in one run since the init
           script has already been received.
         */
         if (this.debug) trace("creating a nework component");
         var net = new Network(this.world);
         net.setConnection(conn);
         net.run(1);
         
         // Run the component in the local world.
         net.execute("getname");
         var name = net.pop();
         if (this.debug) trace("adding network component " +
                               "'" + name + "' to the world");
         this.world.addComponent(name, net);

         // Remove the connection from the connection list but do
         // not close it
         this.connections.remove(conn);
      }
   }

   private function blocking(e : Dynamic) : Bool
   {
      return ("Blocking" == e ||
              "Blocked" == e ||
              haxe.io.Error.Blocked == e);
   }

   private function close(conn : Connection)
   {
      conn.close();
      this.connections.remove(conn);
   }
   
   // Word

   private function listen()
   {
      var host = this.stack.pop();
      var port = Std.parseInt(this.stack.pop());
      
      try
      {
         var host = new neko.net.Host(host);
         this.listenSocket.bind(host, port);
         this.listenSocket.listen(10);
         this.acceptingConnections = true;
         if (this.debug) trace("listening on " +
                               host + ":" + port);
      }
      catch (e : Dynamic)
      {
         trace(e);
      }
   }

   private function destroy()
   {
      try
      {
         this.listenSocket.close();
      }
      catch (e : Dynamic)
      {
      }
   }

#else

   public override function run(steps : Int)
   {
   }
   
#end
}

