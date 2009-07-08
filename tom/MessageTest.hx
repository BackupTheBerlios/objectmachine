
/**

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

Unit tests for the tom.Message class.

*/

package tom;

class MessageTest extends haxe.unit.TestCase
{
    public function testSplit()
    {
        // The word 'message' should split the message in two,
        // into a header and a body. The header is executed
        // while the body is not.
        
        var message : Message = new Message();
        
        message.execute( "thesender sender thereceiver receiver message 3 4");
        
        this.assertEquals("thesender", message.getSender());
        this.assertEquals("thereceiver", message.getReceiver());
        this.assertEquals(null, message.pop());
    }

    public function testMultipleSendersReceivers()
    {
        var message : Message = new Message();
        
        message.execute( "sender1 sender sender2 sender receiver1 receiver receiver2 receiver message 3 4");
        
        this.assertEquals("sender1", message.getSender());
        this.assertEquals("receiver1", message.getReceiver());
        this.assertEquals(null, message.pop());
    }
}
