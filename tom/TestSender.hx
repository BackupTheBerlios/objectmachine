
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

  The TestSender class is only used to test the message passing
  functionality of the world.

*/

package tom;

class TestSender extends Object
{
   public function new(world : World)
   {
      super(world);
        
      this.words.set( "test1", Reflect.field(this, "test1"));
      this.words.set("test2", Reflect.field(this, "test2"));
   }

   public override function run(steps : Int)
   {
      super.run(steps);

      if (this.debug) trace("checking messages");
      this.checkMessages();
   }
    
    
   // Private
    
   // Words
    
   private function test1()
   {
      // Send a message to a component called 'testreceiver'
      // containing the single word 'hello'.
        
      var message = new Message();
      var txt : String;
      txt  = " testsender sender";
      txt += " testreceiver receiver";
      txt += " message";
      txt += " hello";
      message.execute(txt);
      this.sendMessage(message);
   }

   private function test2()
   {
      // Send a message containing the single word 'done' to a
      // component called 'testreceiver' living in world 'b'.
        
      var message = new Message();
      var txt = "testsender sender " +
         "b.testreceiver receiver " +
         "message " +
         "done";
      message.execute(txt);
      this.sendMessage(message);
   }
}
