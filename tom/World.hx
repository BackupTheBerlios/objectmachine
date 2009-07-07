
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

The World class creates and owns all object/components living in the TOM world.

*/

package tom;

class World extends Object, implements Runnable
{
    public function new()
    {
        super();
        
        this.components = new Hash<Runnable>();
        
        this.words.set( "create", Reflect.field(this, "create"));
        this.words.set( "exists", Reflect.field(this, "exists"));
        this.words.set( "sender", Reflect.field(this, "sender"));
        this.words.set( "receiver", Reflect.field(this, "receiver"));
    }
    
    public function run(steps : Int)
    {
        var component : Dynamic;
        for (component in this.components)
        {
            component.run(1);
            this.deliverMessages(component);
        }
        this.readOwnMessages();
    }
    
    
    // Private
    
    private function createComponent(name : String, component : Dynamic)
    {
        component.execute(name + " name");
        this.components.set(name, component);
    }
    
    private function deliverMessages(component : Dynamic)
    {
        // Deliver at most 10 messages at a time
        var i : Int;
        for (i in 0...10)
        {
            if (!this.deliverOneMessage(component)) break;
        }
    }
    
    private function deliverOneMessage(component : Dynamic) : Bool
    {
        var message = component.getMessage();
        if (null == message)    return false;
        this.execute(message);
        var receivingComponent : Dynamic;
        if (this.theReceiver == this.myName)    // The message is to the world
        {
            receivingComponent = this;
        }
        else
        {
            receivingComponent = this.components.get(this.theReceiver);
        }
        if (null != receivingComponent)
        {
            message = this.extractMessage(message);
            // Reconstruct the message header
            message = this.theSender + " sender " + this.theReceiver + " receiver message " + message;
            receivingComponent.putMessage(message);
        }
        return true;
    }
    
    private function readOwnMessages()
    {
        // Read at most 10 messages at a time
        var i : Int;
        for (i in 0...10)
        {
            var message = this.receiveMessage();
            if (null == message)    break;
            this.execute(message);
            if (this.theReceiver == this.myName)
            {
                message = this.extractMessage(message);
                this.execute(message);
            }
        }
    }

    // Words
    
    private function create()
    {
        var type : String = this.stack.pop();
        var name : String = this.stack.pop();
        
        switch (type)
        {
            case "Network" : this.createComponent(name, new Network());
            case "TestSender" : this.createComponent(name, new TestSender());
            case "TestReceiver" : this.createComponent(name, new TestReceiver());
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
    
    private function sender()
    {
        this.theSender = this.stack.pop();
    }
    
    private function receiver()
    {
        this.theReceiver = this.stack.pop();
    }
    
    
    private var components : Hash<Runnable>;
    
    private var theSender : String;
    private var theReceiver : String;
}
