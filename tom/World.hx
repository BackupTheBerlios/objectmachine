
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

  The World class creates and owns all object/components living
  in the TOM world.

*/

package tom;

class World extends Object
{
   public function new()
   {
      super();
        
      this.components = new Hash<Object>();
      this.domain = "";
        
      this.words.set("create", Reflect.field(this, "create"));
      this.words.set("exists", Reflect.field(this, "exists"));
      this.words.set("domain", Reflect.field(this, "setDomain"));
      this.words.set("getdomain", Reflect.field(this, "getDomain"));
   }
    
   public override function run(steps : Int)
   {
      super.run(steps);

      steps++;
      var i : Int;
      for (i in 1...steps)
      {
         if (this.debug) trace("DOMAIN " + this.domain +
                               " step " + i);
         this.deliverWorldMessages();

         var component : Dynamic;
         for (component in this.components)
         {
            component.run(1);
            this.deliverMessages(component);
         }
      }
   }

   public function addComponent(name :String,
                                component : Dynamic)
   {
      component.execute(name + " name");
      this.components.set(name, component);
   }
   
   public function getComponent(name : String) : Dynamic
   {
      return this.components.get(name);
   }
    
    
   // Private
    
   private var components : Hash<Object>;
   private var domain : String;

   private function deliverWorldMessages()
   {
      // Take message sent to the world and deliver them to the
      // correct receiver.

      if (this.debug) trace("delivering world messages");
      
      // Deliver at most 10 messages at a time
      var count : Int = 0;
      var i : Int;
      for (i in 0...10)
      {
         var message = this.receiveMessage();
         var ok = this.deliverMessage(this, message);
         if (!ok) break;
         count++;
      }
      if (this.debug) trace("delivered " + count + " messages");
   }

   private function deliverMessages(component : Dynamic)
   {
      // Take messages from the component and deliver them to the
      // correct receiver.

      if (this.debug) trace("delivering component messages");
      
      // Deliver at most 10 messages at a time
      var count : Int = 0;
      var i : Int;
      for (i in 0...10)
      {
         var message = component.getMessage();
         var ok = this.deliverMessage(component, message);
         if (!ok) break;
         count++;
      }
      if (this.debug) trace("delivered " + count + " messages");
   }

   private function deliverMessage(component : Dynamic,
                                   message : Message) : Bool
   {
      if (null == message)
      {
         return false;
      }

      var receivingComponent : Dynamic;
      var receiverName = message.getReceiver();
      if (receiverName == "")
      {
         return false;
      }
      if (this.debug)
      {
         trace("message to '" + receiverName + "'");
         trace("message='" + message.body + "'");
      }
      if (receiverName == this.name)
      {
         // The message is to the world - execute it
         this.execute(message.body);
      }
      else
      {
         receivingComponent = this.routeComponent(receiverName);
         if (null != receivingComponent)
         {
            if (this.debug)
            {
               receivingComponent.execute("getname");
               trace("sending message to " +
                     "'" + receivingComponent.pop() + "'");
            }
            receivingComponent.putMessage(message);
         }
         else
         {
            trace("ERROR: No component with name '" +
                  receiverName + "' found");
            // Todo: Send messaeg back to sender, informing him
            // of the failure
            return false;
         }
      }
        
      return true;
   }

   private function routeComponent(name : String) : Object
   {
      if (this.debug) trace("routing '" + name + "'");
      
      var comp;
      var route = name.split(".");
      
      if (1 == route.length)
         comp = this.components.get(name);
      else if (this.domain == route[route.length - 2])
         comp = this.findLocal(route[route.length - 1]);
      else
         comp = this.findRemote(route);

      if (this.debug)
      {
         if (null != comp)
         {
            comp.execute("getname");
            trace("component '" + comp.pop() + "'" + " returned");
         }
         else trace("route to component not found");
      }

      return comp;
   }

   private function findLocal(name : String) : Object
   {
      if (this.debug) trace("searching locally for " +
                            "'" + name + "'");
      if (this.name == name)
         // It is the world itself
         return this;
      else
         // Try to find the component locally
         return this.components.get(name);
   }

   private function findRemote(route : Array<String>) : Object
   {
      if (this.debug) trace("searching for remote route");
      
      // Find a component with a name matching any of the route
      // strings (excluding the last, which is the receiving
      // object) and return it if it exists
      var count = route.length - 1;
      while (count >= 0)
      {
         if (this.debug) trace("checking route " +
                               "'" + route[count] + "'");
         var comp = this.components.get(route[count]);
         if (null != comp) return comp;
         count--;
      }
      
      // Not found
      return null;
   }

   private function addNetworkComponent(name : String)
   {
      var conn;
      if (this.debug) trace("addNetworkComponent");
#if neko
      // Creates the socket when connecting
      conn = new NekoConnection(this.debug);
#elseif flash
      conn = new FlashConnection(this.debug);
      conn.setSocket(new flash.net.Socket());
#end
      var net = new Network(this);
      net.setConnection(conn);
      this.addComponent(name, net);
   }

   // Words
    
   private function create()
   {
      var type : String = this.stack.pop();
      var name : String = this.stack.pop();
        
      switch (type)
      {
      case "Network":
         this.addNetworkComponent(name);
      case "Listener":
         this.addComponent(name, new Listener(this));
      case "TestSender":
         this.addComponent(name, new TestSender(this));
      case "TestReceiver":
         this.addComponent(name, new TestReceiver(this));
         //default : send an error message back
      }
   }
    
   private function exists()
   {
      var name : String = this.stack.pop();
      if (null == name)
      {
         this.stack.push(false);
      }
      else
      {
         this.stack.push(this.components.exists(name));
      }
   }

   private function setDomain()
   {
      this.domain = this.stack.pop();
   }

   private function getDomain()
   {
      this.stack.push(this.domain);
   }
}
