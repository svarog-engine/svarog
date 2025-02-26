//using svarog.runner;
//using SDL2;
//using svarog.input;

//namespace svarog.presentation
//{
//    public class SDL2Presenter : IPresentationLayer
//    {
//        private IntPtr m_Renderer = new();
//        private IntPtr m_Window = new();
//        public void Create(CommandLineOptions options)
//        {
//            //Initialize SDL
//            if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) == 0)
//            {
//                m_Window = SDL.SDL_CreateWindow("SDL Tutorial", SDL.SDL_WINDOWPOS_UNDEFINED, SDL.SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL.SDL_WindowFlags.SDL_WINDOW_SHOWN | SDL.SDL_WindowFlags.SDL_WINDOW_RESIZABLE);
//                if(m_Window != IntPtr.Zero)
//                {
//                    m_Renderer = SDL.SDL_CreateRenderer(m_Window, -1, SDL.SDL_RendererFlags.SDL_RENDERER_SOFTWARE);
//                }
//                else
//                {
//                    Svarog.Instance.LogVerbose($"Window could not be created! SDL_Error: {SDL.SDL_GetError()}");
//                }

//            }
//            else
//            {
//                Svarog.Instance.LogVerbose($"SDL could not initialize! SDL_Error: {SDL.SDL_GetError()}");
//            }
//        }

//        private static string[] MOUSE_BUTTON_NAMES = [
//            "Left",
//            "Right",
//            "Middle",
//            "XButton1",
//            "XButton2" 
//        ];

//        public void Update()
//        {
//            while (SDL.SDL_PollEvent(out SDL.SDL_Event e) == 1)
//            {
//                switch (e.type)
//                {
//                    case SDL.SDL_EventType.SDL_QUIT:

//                        SDL.SDL_DestroyRenderer(m_Renderer);
//                        SDL.SDL_DestroyWindow(m_Window);
//                        SDL.SDL_Quit();

//                        Svarog.Instance.Shutdown();
//                        break;

//                    case SDL.SDL_EventType.SDL_KEYDOWN:
//                        Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Press, $"Key: {e.key.keysym.scancode}", 0));
//                        break;

//                    case SDL.SDL_EventType.SDL_KEYUP:
//                        Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Release, $"Key: {e.key.keysym.scancode}", 0));
//                        break;

//                    case SDL.SDL_EventType.SDL_MOUSEBUTTONDOWN:
//                        Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Press, $"Mouse: {MOUSE_BUTTON_NAMES[(int)e.button.button]}", 1, e.button.x, e.button.y));
//                        break;

//                    case SDL.SDL_EventType.SDL_MOUSEBUTTONUP:
//                        Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Release, $"Mouse: {MOUSE_BUTTON_NAMES[(int)e.button.button]}", 1, e.button.x, e.button.y));
//                        break;

//                    case SDL.SDL_EventType.SDL_MOUSEMOTION:
//                        Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Hold, "Mouse: Move", 0, e.motion.x, e.motion.y));
//                        break;
//                }
//            }
//            SDL.SDL_SetRenderDrawColor(m_Renderer, 135, 206, 235, 255);

//            SDL.SDL_RenderClear(m_Renderer);

//            SDL.SDL_RenderPresent(m_Renderer);
//        }

//        public void Reload()
//        {
//            // TBD
//        }
//    }
//}
