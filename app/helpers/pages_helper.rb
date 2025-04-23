module PagesHelper
  def faq_questions
    [
      {
        question: "What's included in the Free plan?",
        answer: "Once you sign up and create your Maybe account, you'll be able to connect up to 3 accounts. You'll also be able to do things like tracking transactions, investments and set up a budget. You will not have access to Maybe AI until you upgrade to Maybe Plus."
      },
      {
        question: "What's included in Maybe Plus?",
        answer: "Maybe Plus gives you full access to Maybe AI, lets you connect unlimited accounts across all types, and includes priority customer support. You'll also get early access to new features as they're released, along with everything already available in the Free plan."
      },
      {
        question: "How is my payment being processed?",
        answer: "All payments are securely processed through Stripe. Maybe Plus is billed either monthly at $9 per month or annually at $90 per year. You'll receive an email confirmation once the payment goes through."
      },
      {
        question: "What is your refund policy?",
        answer: "If Maybe Plus doesn't work for you, we offer a full refund—no questions asked. Just reach out to us at <a href='mailto:hey@maybe.co' class='font-medium text-gray-900'>hey@maybe.co</a> and we'll take care of it."
      },
      {
        question: "Can I cancel my subscription at any time?",
        answer: "Yes, you can cancel whenever you like. Your Maybe Plus benefits will remain active until the end of your current billing period, and you won't be charged again after that."
      }
    ]
  end
end
