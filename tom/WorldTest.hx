
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

  Unit tests for the tom.World class.

*/

package tom;

class WorldTest extends haxe.unit.TestCase
{
   public override function setup()
   {
      // Note that both the worlds are called the same but each
      // serves a different domain
        
      this.world1 = new World();
      this.world1.execute("world name");
      this.world1.execute("a domain");

      this.world2 = new World();
      this.world2.execute("world name");
      this.world2.execute("b domain");
   }

   public override function tearDown()
   {
      this.world1 = null;
      this.world2 = null;
   }
	
   private var world1 : World;
   private var world2 : World;
	    
   public function testCreateNetwork()
   {
      /*
        Test the 'create' script word which creates new objects
        that live in the world. The query word 'exists' is used
        to confirm the existence of new object.
        
        Examples:
        
        'abcd Network create' creates an object of type
        Network  and names it 'abcd'.
        
        'abcd exists' puts true on the stack if the component
        exists.
      */

      this.world1.execute("abcd Network create");
      this.world1.execute("abcd exists");
        
      this.assertEquals(true , this.world1.pop());
   }

   public function testNotExists()
   {
      this.world1.execute("abcd Network create");
      this.world1.execute("dummy exists");
        
      this.assertEquals(false , this.world1.pop());
   }

   public function testPutMessage()
   {
      /*
        This test sends a message to the world.
        This tests the same function the world uses to send
        messages to the components it is running (the world is
        a component). Once it receives it, it will execute the
        content as a script. Since no words come after the
        last text in the script it will be left on the stack
        where we can check for it.
      */
       
      // Send the worl a message
      var msgText : String;
      msgText  = "putmessage sender ";
      msgText += "world receiver ";
      msgText += "message ";
      msgText += '" hello there "';
      var msg : Message = new Message();
      msg.execute(msgText);
      this.world1.putMessage(msg);
        
      this.world1.run(1);
        
      this.assertEquals("hello there", this.world1.pop());
   }

   public function testMessageSend()
   {
      /*
        This test creates two components, one sender and one
        receiver.  The sender tries to send a message to the
        receiver containing the text 'hello'.
        We test the result by asking the world to give us the
        receiving component and then we can ask it directly
        what it got.
      */
        
      this.world1.execute("testsender TestSender create");
      this.world1.execute("testreceiver TestReceiver create");
        
      // Ask the sender to run test1
      var msgText : String;
      msgText  = " testsender receiver";
      msgText += " message";
      msgText += " test1";
      var msg : Message = new Message();
      msg.execute(msgText);
      this.world1.putMessage(msg);

      this.world1.run(1);
      this.world1.run(1);

      var component = this.world1.getComponent("testreceiver");
      var res = component.pop();
      this.assertEquals("hello", res);

   }

#if neko
   
   public function testWorldCommunication()
   {
      //trace("testWorldCommunication ****************");
      /*
        This test only applies to worlds run by neko.
        
        Connect the two worlds, world1 and world2, over the
        network, create a sender in world 1, who sends a message
        containing the word 'done' to the receiver, and a receiver
        in world 2, who waits for the message from the sender,
        and run the worlds for a while or until the receiver has
        the text 'done' on its stack.
      */
        
      var txt : String;
        
      // Create the network component in world 1 that routes
      // messages to domain b
      //trace("1**********");
      var msg = new Message();
      txt = "world receiver " +
         "message " +
         "b Network create";
      msg.execute(txt);
      this.world1.putMessage(msg);
      //this.world1.run(2);
      //this.world1.execute("b exists");
      //this.assertEquals(true, this.world1.pop());
      
      // Create the test sender in world 1
      //trace("2**********");
      msg = new Message();
      txt = "world receiver " +
         "message " +
         "testsender TestSender create";
      msg.execute(txt);
      this.world1.putMessage(msg);
      //this.world1.run(2);
      //this.world1.execute("testsender exists");
      //this.assertEquals(true, this.world1.pop());
      
      // Create the network listener in world 2
      //trace("3**********");
      msg = new Message();
      txt = "world receiver " +
         "message " +
         "listener Listener create";
      msg.execute(txt);
      this.world2.putMessage(msg);
      //this.world2.run(2);
      //this.world2.execute("listener exists");
      //this.assertEquals(true, this.world2.pop());

      // Tell the network listener in world to listen on port
      // 5000 at localhost
      //trace("4**********");
      msg = new Message();
      txt = "listener receiver " +
         "message " +
         "5000 localhost listen";
      msg.execute(txt);
      this.world2.putMessage(msg);
      //this.world2.run(2);

      // Tell the network component in world 1, who is routing
      // to domain b, to connect to world 2 (which handles
      // domain b - see the setup function)
        
      /*
        Reminder: The connection handshake includes
        information on from which domain the connection is
        coming from. This is crucial, since the listener has
        to name the network component it creates the same name as
        the sender's world in order for the routing to work
        correctly.
      */
      //trace("5**********");
      msg = new Message();
      txt = "b receiver " +
         "message " +
         "5000 localhost connect";
      msg.execute(txt);
      this.world1.putMessage(msg);
      //this.world1.run(2);
      //this.world2.run(2);
      //this.world1.run(2);
      //this.world2.run(2);

      // Create the receiver in world 2
      // (I could send a message through world 1 asking world 2
      // to create the receiver, but let's save that for another
      // test)
      //trace("6**********");
      msg = new Message();
      txt = "world receiver " +
         "message " +
         "testreceiver TestReceiver create";
      msg.execute(txt);
      this.world2.putMessage(msg);
      //this.world2.run(1);

      // Finally, ask the test sender to run test2
      //trace("7**********");
      msg = new Message();
      txt = "testsender receiver message " +
         "test2";
      msg.execute(txt);
      this.world1.putMessage(msg);
      //this.world1.run(2);
      //this.world2.run(2);
      
      // Normally, a world is run in its own process and runs
      // forever.
      // Just run them alternately here.
      //trace("8**********");
      var res = "";
      var i : Int;
      for (i in 0...10)
      {
         this.world2.run(1);
         this.world1.run(1);

         var comp = this.world2.getComponent("testreceiver");
         if (null != comp)
         {
            res = comp.pop();
            if ("done" == res)  break;
         }
      }
      
      this.assertEquals("done" , res);

      var comp;
      comp = this.world1.getComponent("b");
      comp.execute("destroy");
      comp = this.world2.getComponent("listener");
      comp.execute("destroy");
      comp = this.world2.getComponent("a");
      comp.execute("destroy");
   }

#end

   
}
