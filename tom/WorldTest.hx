
/*

Copyright 2009 The Object Machine Project. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE OBJECT MACHINE PROJECT ``AS IS'' AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE OBJECT MACHINE PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

The views and conclusions contained in the software and documentation are those of
the authors and should not be interpreted as representing official policies, either
expressed or implied, of The Object Machine Project.

*/

/*

Unit tests for the tom.World class.

*/

package tom;

class WorldTest extends haxe.unit.TestCase
{
    // Test the 'create' script word which creates new objects that live in the world.
    // The query word 'exists' is used to confirm the existence of new object.
    // Examples:
    //  'abcd Network create' creates an object of type Network and names it 'abcd'.
    //  'abcd exists' puts true on the stack if the object exists.
    
    public function testCreateNetwork()
    {
        var world : World = new World();
        
        world.execute( "abcd Network create");
        world.execute( "abcd exists");
        
        this.assertEquals( true , world.pop());
    }

    public function testNotExists()
    {
        var world : World = new World();
        
        world.execute( "abcd Network create");
        world.execute( "dummy exists");
        
        this.assertEquals( false , world.pop());
    }

    public function testPutMessage()
    {
        // This test sends a message to the world.
        // This is the same function the world uses to send messages
        // to the components it is running (the world is a component).
        // Once it receives it, it will execute the content as a script.
        // Since no words come after the last text in the script
        // it will be left on the stack where we can check for it.
       
        var world : World = new World();
        
        // Name the world
        world.execute( "world name");
        
        // Send it a message
        var msgText : String;
        msgText  = " me sender";
        msgText += " world receiver";
        msgText += " message";
        msgText += ' " hello there "';
        var msg : Message = new Message();
        msg.execute(msgText);
        world.putMessage(msg);
        
        world.run(1);
        
        this.assertEquals( "hello there", world.pop());
    }

    public function testMessageSend()
    {
        // This test creates two components, one sender and one receiver.
        // The sender tries to send a message to the receiver containing
        // the text 'hello'.
        // We test the result by asking the world to give us the receiving
        // component and then we can ask it directly what it got.
        
        var world : World = new World();
        
        world.execute( "world name");
        
        world.execute( "testsender TestSender create");
        world.execute( "testreceiver TestReceiver create");
        
        // Ask the sender to run test1
        var msgText : String;
        msgText  = " testsender receiver";
        msgText += " message";
        msgText += " test1";
        var msg : Message = new Message();
        msg.execute(msgText);
        world.putMessage(msg);

        world.run(1);

        this.assertEquals( "hello" , world.getComponent("testreceiver").pop());
    }
    
    /*
    public function testMessageConfirmation()
    {
        // Test if the message confirmation reaches the sender
        
        var world : World = new World();

        world.execute( "world name");
        
        world.execute( "testsender TestSender create");
        world.execute( "testreceiver TestReceiver create");

        // Ask the sender to run test2
        var msg;
        msg  = " testsender receiver";
        msg += " message";
        msg += " test2";
        world.putMessage(msg);
        
        world.run(1);
        
        this.assertEquals( "hello" , world.pop());
    }
    */
}
