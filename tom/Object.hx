
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

Object is the base class for all classes in The Object Machine (TOM) framework

It implements the common functionality needed by all the other classes.
All TOM objects understand a scripting interface which is implemented by
a stack based parser in the Object class and can be extended by the child
classes in a very easy way. For example, the Object class can extract text
strings from the script which can then be used by a child class implementing
some custom command in the script which has been linked to a method in the
child class.

*/

package tom;

class Object
{
    public function new()
    {
        this.myName = "";
        
        this.receivedMessages = new List<Message>();
        this.sentMessages = new List<Message>();
        this.stack = new List<Dynamic>();
        this.words = new Hash<Dynamic>();
        
        this.words.set( '"', Reflect.field(this, "text"));
        this.words.set( "name", Reflect.field(this, "name"));
        this.words.set( "getname", Reflect.field(this, "getName"));
    }
    
    public function execute(script : String) : Void
    {
        /*
        A script consists of commands called 'words' which are separated
        by whitespace (space, tab, newline). If a word is recognized it is
        executed, otherwise it is pushed on the stack in the form of a string.
        Each class inheriting from Object can extend the scripting capability
        by adding words to this.words (see the constructor above). The parser
        will then recognize this new word when a script is executed and call
        the new method added by the child class.
        
        Maybe it's more efficient to do this one word at a time from the
        script text (instead of splitting it all up at once) if there are a lot
        of text strings (which there probably will be).
        The '"' command will then have to remove the text string from the script,
        otherwise the parser will get confused.
        
        Anyway, this is the simplest thing to do right now.
        */
        
        this.scriptWords = script.split( " ");
        
        var wordCount = this.scriptWords.length;
        this.currentWordIndex = 0;
        while (this.currentWordIndex < wordCount)
        {
            var word = this.scriptWords[this.currentWordIndex++];
            var method = this.words.get(word);
            if (null != method)
            {
                // Execute the method associated with the word
                Reflect.callMethod(this, method, []);
            }
            else
            {
                // Word not found. Add it to the stack if it is not empty
                if (StringTools.trim(word) != "")
                {
                    this.stack.push(word);
                }
            }
        }
    }
    
    public function pop() : Dynamic
    {
        return this.stack.pop();
    }

    // Used by the world the deliver messages to the component
    public function putMessage(message : Message)
    {
        this.receivedMessages.add(message);
    }
    
    // Used by the world the deliver messages from the component
    public function getMessage() : Message
    {
        return this.sentMessages.pop();
    }
    
    
    // Private
    
    // Used by the component to receive messages
    private function receiveMessage() : Message
    {
        return this.receivedMessages.pop();
    }
    
    // Used by the component to send messages
    private function sendMessage(message : Message)
    {
        this.sentMessages.add(message);
    }
    
    // Words
    
    private function text()
    {
        var string : String = "";
        while (true)
        {
            string += this.scriptWords[this.currentWordIndex];
            if ( '"' == this.scriptWords[++this.currentWordIndex])   break;
            string += " ";
        }
        this.currentWordIndex++;    // Skip the " at the end
        this.stack.push(string);
    }
    
    private function name()
    {
        this.myName = this.stack.pop();
    }
    
    private function getName()
    {
        this.stack.push(this.myName);
    }
    
    // Instance variables
    
    private var myName : String;
    
    private var words : Hash<Dynamic>;
    private var scriptWords : Array<String>;
    private var currentWordIndex : Int;
    
    private var stack : List<Dynamic>;
    
    private var receivedMessages : List<Message>;
    private var sentMessages : List<Message>;
}
