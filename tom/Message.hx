
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

  The Message class parses messages and keeps track of its sender
  and receiver(s).

  A message never runs in a world.

*/

package tom;

class Message extends Object
{
   public var header(default, null) : String;
   public var body(default, null) : String;
   public var headerBodyCombined(getCombined, null) : String;

   public function new()
   {
      super();
      
      this.senders = new List<String>();
      this.receivers = new List<String>();
      this.header = "";
      this.body = "";
      
      this.words.set("sender", Reflect.field(this, "sender"));
      this.words.set("receiver", Reflect.field(this, "receiver"));
   }

   public override function execute(text : String)
   {
      // If the text is like this 'aaa aaa message bbb bbb
      // message cc cc', I want two halves: 'aaa aaa' and 'bbb
      // bbb message cc cc', the first 'message' substring being
      // the splitter, and then only execute the first half. I do
      // this to minimize the execution time and to avoid
      // side-effects from the message body. 

      if (this.debug) trace("text='" + text + "'");
      var messageStart = text.indexOf( " message ");
      if (-1 != messageStart)
      {
         this.header = text.substr(0, messageStart);
         if (this.debug) trace("header='" + this.header + "'");
         super.execute(this.header);

         this.body = text.substr(messageStart + 9);
         if (this.debug) trace("body='" + this.body + "'");
      }
   }
    
   public function getSender() : String
   {
      var s = this.senders.first();
      if (null == s)  s = "";
      return s;
   }

   public function getReceiver() : String
   {
      var r = this.receivers.first();
      if (null == r)  r = "";
      return r;
   }
    
   public function isTo(name : String) : Bool
   {
      return this.receivers.first() == name;
   }
    
   // Private
    
   private var senders : List<String>;
   private var receivers : List<String>;

   private function getCombined() : String
   {
      return this.header + " message " + this.body;
   }
   
   // Words
    
   private function sender()
   {
      var res = this.stack.pop();
      if (this.debug) trace("sender='" + res + "'");
      this.senders.add(res);
   }

   private function receiver()
   {
      var res = this.stack.pop();
      if (this.debug) trace("receiver='" + res + "'");
      this.receivers.add(res);
   }
}
