# ChatPrototype

This is a chat prototype with real-time messages using Phoenix LiveView.

## Endpoints
- Get - `/api/rooms`
- Post - `/api/rooms`

  _Payload example_
  ```json
    {
	     "name": "Football"
    }
  ```

## Room processes structure
![structure](https://github.com/ruimfernandes/chat_prototype/assets/18558899/98bfbd3f-684c-479d-8d84-e014f3249ec1)

_Description_
- Circles are supervisors
- Squares are processes


## How to run
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


