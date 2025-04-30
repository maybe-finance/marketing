module PagesHelper
  def faq_questions
    [
      {
        question: "How is my payment being processed?",
        answer: "All payments are securely processed through Stripe. Maybe is billed either monthly at $9 per month or annually at $90 per year. You'll receive an email confirmation once the payment goes through."
      },
      {
        question: "What is your refund policy?",
        answer: "If Maybe doesn't work for you, we offer a full refund—no questions asked. Just reach out to us at <a href='mailto:hello@maybe.co' class='font-medium text-gray-900'>hello@maybe.co</a> and we'll take care of it."
      },
      {
        question: "Can I cancel my subscription at any time?",
        answer: "Yes, you can cancel whenever you like. Your Maybe benefits will remain active until the end of your current billing period, and you won't be charged again after that."
      },
      {
        question: "What are your data privacy & security policies?",
        answer: "We take your data privacy and security seriously. Please refer to our <a href='https://maybe.co/privacy' class='font-medium text-gray-900'>Privacy Policy</a> for more information."
      },
      {
        question: "Is  Maybe open source?",
        answer: "Yes, Maybe is open source. You can find the source code on <a href='https://github.com/maybe-finance/maybe' class='font-medium text-gray-900'>GitHub</a>."
      },
      {
        question: "Can I self-host Maybe?",
        answer: "Yes, you can self-host Maybe. Please refer to the <a href='https://github.com/maybe-finance/maybe' class='font-medium text-gray-900'>GitHub repository</a> for more information."
      }
    ]
  end
end
